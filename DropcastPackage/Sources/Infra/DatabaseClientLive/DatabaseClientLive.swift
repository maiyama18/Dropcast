import AsyncAlgorithms
@preconcurrency import CoreData
import DatabaseClient
import Dependencies
import Entity
import Error

extension DatabaseClient {
    static func live(persistentProvider: PersistentProvider) -> DatabaseClient {
        final class Delegate: NSObject, NSFetchedResultsControllerDelegate, Sendable {
            let showsStream: AsyncChannel<[Show]> = .init()

            func sendInitialValue(_ controller: NSFetchedResultsController<ShowRecord>) {
                try? controller.performFetch()
                let shows = controller.fetchedObjects?.compactMap { $0.toShow() } ?? []
                Task {
                    await showsStream.send(shows)
                }
            }

            func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
                guard let records = controller.fetchedObjects as? [ShowRecord] else { return }
                let shows = records.compactMap { $0.toShow() }
                Task {
                    await showsStream.send(shows)
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

        let showsController = persistentProvider.executeInBackground { context in
            context.automaticallyMergesChangesFromParent = true
            return NSFetchedResultsController(
                fetchRequest: showsRequest,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
        }

        return DatabaseClient(
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
            followedShowsStream: {
                showsController.delegate = delegate
                delegate.sendInitialValue(showsController)

                return delegate.showsStream
            }
        )
    }
}

extension DatabaseClient: DependencyKey {
    public static let liveValue: DatabaseClient = DatabaseClient.live(persistentProvider: CloudKitPersistentProvider.shared)
}
