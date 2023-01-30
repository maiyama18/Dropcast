import CoreData
import DatabaseClient
import Dependencies
import Error

extension DatabaseClient {
    static func live(persistentProvider: PersistentProvider) -> DatabaseClient {
        return DatabaseClient(
            followShow: { show in
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
