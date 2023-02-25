import Algorithms
import AsyncAlgorithms
@preconcurrency import CoreData
import CustomDump
import Dependencies
import Entity
import Error
import Foundation
import IdentifiedCollections
import Logger

public struct DatabaseClient: Sendable {
    public var fetchShow: @Sendable (URL) -> Result<Show?, DatabaseError>
    public var followShow: @Sendable (Show) -> Result<Void, DatabaseError>
    public var unfollowShow: @Sendable (URL) -> Result<Void, DatabaseError>
    public var followedShowsStream: @Sendable () -> AsyncChannel<IdentifiedArrayOf<Show>>
    public var followedEpisodesStream: @Sendable () -> AsyncChannel<IdentifiedArrayOf<Episode>>

    public init(
        fetchShow: @escaping @Sendable (URL) -> Result<Show?, DatabaseError>,
        followShow: @escaping @Sendable (Show) -> Result<Void, DatabaseError>,
        unfollowShow: @escaping @Sendable (URL) -> Result<Void, DatabaseError>,
        followedShowsStream: @escaping @Sendable () -> AsyncChannel<IdentifiedArrayOf<Show>>,
        followedEpisodesStream: @escaping @Sendable () -> AsyncChannel<IdentifiedArrayOf<Episode>>
    ) {
        self.fetchShow = fetchShow
        self.followShow = followShow
        self.unfollowShow = unfollowShow
        self.followedShowsStream = followedShowsStream
        self.followedEpisodesStream = followedEpisodesStream
    }
}

extension DatabaseClient {
    public static func live(persistentProvider: PersistentProvider) -> DatabaseClient {
        @Dependency(\.logger[.database]) var logger

        final class Delegate: NSObject, NSFetchedResultsControllerDelegate, Sendable {
            let showsStream: AsyncChannel<IdentifiedArrayOf<Show>> = .init()
            let episodesStream: AsyncChannel<IdentifiedArrayOf<Episode>> = .init()

            func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
                if let showRecords = controller.fetchedObjects as? [ShowRecord] {
                    sendFetchedShowRecords(showRecords)
                } else if let episodeRecords = controller.fetchedObjects as? [EpisodeRecord] {
                    sendFetchedEpisodeRecords(episodeRecords)
                } else {
                    assertionFailure()
                }
            }

            func sendShowsInitialValue(_ controller: NSFetchedResultsController<ShowRecord>) {
                try? controller.performFetch()
                guard let records = controller.fetchedObjects else { return }
                sendFetchedShowRecords(records)
            }

            func sendEpisodesInitialValue(_ controller: NSFetchedResultsController<EpisodeRecord>) {
                try? controller.performFetch()
                guard let records = controller.fetchedObjects else { return }
                sendFetchedEpisodeRecords(records)
            }

            private func sendFetchedShowRecords(_ records: [ShowRecord]) {
                @Dependency(\.logger[.database]) var logger

                let shows = records.compactMap { $0.toShow() }
                let uniquedShows = shows.uniqued(on: { $0.feedURL })
                let identifiedShows = IdentifiedArrayOf(uniqueElements: uniquedShows)
                logger.notice("sending fetched shows:\n\(customDump(identifiedShows))")
                Task {
                    await showsStream.send(identifiedShows)
                }
            }

            private func sendFetchedEpisodeRecords(_ records: [EpisodeRecord]) {
                @Dependency(\.logger[.database]) var logger

                let episodes = records.compactMap { $0.toEpisode() }
                let uniquedEpisodes = episodes.uniqued(on: { $0.id })
                let identifiedEpisodes = IdentifiedArrayOf(uniqueElements: uniquedEpisodes)
                logger.notice("sending fetched episodes:\n\(customDump(identifiedEpisodes))")
                Task {
                    await episodesStream.send(identifiedEpisodes)
                }
            }
        }

        @Sendable
        func fetchShow(feedURL: URL) -> Result<Show?, DatabaseError> {
            persistentProvider.executeInBackground { context in
                let request = ShowRecord.fetchRequest()
                request.predicate = NSPredicate(format: "%K = %@", #keyPath(ShowRecord.feedURL), feedURL as NSURL)
                logger.notice("fetching show: \(feedURL, privacy: .public)")
                do {
                    let records = try context.fetch(request)
                    let show = records.first?.toShow()
                    logger.notice("show response:\n\(customDump(show), privacy: .public)")
                    return .success(show)
                } catch {
                    logger.fault("failed to fetch show: \(error, privacy: .public)")
                    return .failure(.databaseError)
                }
            }
        }

        let delegate = Delegate()

        let showsRequest = ShowRecord.fetchRequest()
        showsRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \ShowRecord.title, ascending: true)
        ]

        let episodesRequest = EpisodeRecord.fetchRequest()
        episodesRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \EpisodeRecord.publishedAt, ascending: false)
        ]

        let showsController = persistentProvider.executeInBackground { context in
            context.automaticallyMergesChangesFromParent = true
            return NSFetchedResultsController(
                fetchRequest: showsRequest,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
        }

        let episodesController = persistentProvider.executeInBackground { context in
            context.automaticallyMergesChangesFromParent = true
            return NSFetchedResultsController(
                fetchRequest: episodesRequest,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
        }

        return DatabaseClient(
            fetchShow: fetchShow(feedURL:),
            followShow: { show in
                logger.notice("following show: \(show.feedURL, privacy: .public)")
                switch fetchShow(feedURL: show.feedURL) {
                case .success(let show):
                    guard show == nil else {
                        // returns no error because show is already followed
                        logger.warning("show is already followed")
                        return .success(())
                    }
                case .failure(let error):
                    return .failure(error)
                }

                return persistentProvider.executeInBackground { context in
                    _ = ShowRecord(context: context, show: show)
                    do {
                        try context.save()
                        logger.notice("followed show: \(customDump(show), privacy: .public)")
                        return .success(())
                    } catch {
                        context.rollback()
                        logger.fault("failed to follow show: \(error, privacy: .public)")
                        return .failure(.databaseError)
                    }
                }
            },
            unfollowShow: { feedURL in
                persistentProvider.executeInBackground { context in
                    logger.notice("unfollowing show: \(feedURL, privacy: .public)")
                    let request = ShowRecord.fetchRequest()
                    request.predicate = NSPredicate(format: "%K = %@", #keyPath(ShowRecord.feedURL), feedURL as NSURL)

                    let record: ShowRecord
                    do {
                        let records = try context.fetch(request)
                        guard let firstRecord = records.first else {
                            // returns no error because show is not followed
                            logger.warning("show is not followed")
                            return .success(())
                        }
                        record = firstRecord
                    } catch {
                        logger.fault("failed to fetch show to unfollow: \(error, privacy: .public)")
                        return .failure(.databaseError)
                    }

                    context.delete(record)
                    do {
                        try context.save()
                        logger.notice("unfollowed show: \(feedURL, privacy: .public)")
                        return .success(())
                    } catch {
                        context.rollback()
                        logger.fault("failed to follow show: \(error, privacy: .public)")
                        return .failure(.databaseError)
                    }
                }
            },
            followedShowsStream: {
                showsController.delegate = delegate
                delegate.sendShowsInitialValue(showsController)

                return delegate.showsStream
            },
            followedEpisodesStream: {
                episodesController.delegate = delegate
                delegate.sendEpisodesInitialValue(episodesController)

                return delegate.episodesStream
            }
        )
    }
}

extension DatabaseClient: DependencyKey {
    public static let liveValue: DatabaseClient = DatabaseClient.live(persistentProvider: CloudKitPersistentProvider.shared)
    public static let testValue: DatabaseClient = DatabaseClient(
        fetchShow: unimplemented(),
        followShow: unimplemented(),
        unfollowShow: unimplemented(),
        followedShowsStream: unimplemented(),
        followedEpisodesStream: unimplemented()
    )
    public static let previewValue: DatabaseClient = DatabaseClient.live(persistentProvider: InMemoryPersistentProvider())
}
extension DatabaseClient: TestDependencyKey {
}

extension DependencyValues {
    public var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}
