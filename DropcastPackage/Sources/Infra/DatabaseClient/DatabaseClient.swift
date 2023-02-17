import Algorithms
import AsyncAlgorithms
@preconcurrency import CoreData
import Dependencies
import Entity
import Error
import Foundation
import IdentifiedCollections

public struct DatabaseClient: Sendable {
    public var fetchShow: @Sendable (URL) throws -> Show?
    public var followShow: @Sendable (Show) throws -> Void
    public var unfollowShow: @Sendable (URL) throws -> Void
    public var followedShowsStream: @Sendable () -> AsyncChannel<IdentifiedArrayOf<Show>>
    public var followedEpisodesStream: @Sendable () -> AsyncChannel<IdentifiedArrayOf<Episode>>

    public init(
        fetchShow: @escaping @Sendable (URL) throws -> Show?,
        followShow: @escaping @Sendable (Show) throws -> Void,
        unfollowShow: @escaping @Sendable (URL) throws -> Void,
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
                let shows = records.compactMap { $0.toShow() }
                let uniquedShows = shows.uniqued(on: { $0.feedURL })
                let identifiedShows = IdentifiedArrayOf(uniqueElements: uniquedShows)
                Task {
                    await showsStream.send(identifiedShows)
                }
            }

            private func sendFetchedEpisodeRecords(_ records: [EpisodeRecord]) {
                let episodes = records.compactMap { $0.toEpisode() }
                let uniquedEpisodes = episodes.uniqued(on: { $0.id })
                let identifiedEpisodes = IdentifiedArrayOf(uniqueElements: uniquedEpisodes)
                Task {
                    await episodesStream.send(identifiedEpisodes)
                }
            }
        }

        @Sendable
        func fetchShow(feedURL: URL) throws -> Show? {
            try persistentProvider.executeInBackground { context in
                let request = ShowRecord.fetchRequest()
                request.predicate = NSPredicate(format: "%K = %@", #keyPath(ShowRecord.feedURL), feedURL as NSURL)
                let records = try context.fetch(request)
                return records.first?.toShow()
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
                guard try fetchShow(feedURL: show.feedURL) == nil else {
                    return
                }

                try persistentProvider.executeInBackground { context in
                    _ = ShowRecord(context: context, show: show)
                    do {
                        try context.save()
                    } catch {
                        context.rollback()
                        throw DatabaseError.followError
                    }
                }
            },
            unfollowShow: { feedURL in
                try persistentProvider.executeInBackground { context in
                    let request = ShowRecord.fetchRequest()
                    request.predicate = NSPredicate(format: "%K = %@", #keyPath(ShowRecord.feedURL), feedURL as NSURL)
                    let records = try context.fetch(request)
                    guard let record = records.first else { return }
                    context.delete(record)
                    do {
                        try context.save()
                    } catch {
                        context.rollback()
                        throw DatabaseError.unfollowError
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
