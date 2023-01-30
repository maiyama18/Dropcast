import CoreData
import DatabaseClient
import Dependencies
import Entity
import Error

extension DatabaseClient {
    static func live(persistentProvider: PersistentProvider) -> DatabaseClient {
        @Sendable
        func fetchShow(feedURL: URL) throws -> Show? {
            try persistentProvider.executeInBackground { context in
                let request = ShowRecord.fetchRequest()
                request.predicate = NSPredicate(format: "%K = %@", #keyPath(ShowRecord.feedURL), feedURL as NSURL)
                let records = try context.fetch(request)
                return records.first?.toShow()
            }
        }

        return DatabaseClient(
            followShow: { show in
                guard try fetchShow(feedURL: show.feedURL) == nil else {
                    throw DatabaseError.alreadyFollowed
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
            fetchFollowingShows: {
                try persistentProvider.executeInBackground { context in
                    let request = ShowRecord.fetchRequest()
                    request.sortDescriptors = [
                        NSSortDescriptor(keyPath: \ShowRecord.title, ascending: true)
                    ]
                    let records = try context.fetch(request)
                    return records.compactMap { $0.toShow() }
                }
            }
        )
    }
}

extension DatabaseClient: DependencyKey {
    public static let liveValue: DatabaseClient = DatabaseClient.live(persistentProvider: CloudKitPersistentProvider.shared)
}
