import CoreData
import Dependencies

protocol PersistentProvider: Sendable {
    func executeInBackground<T: Sendable>(operation: (NSManagedObjectContext) throws -> T) rethrows -> T
}

final class CloudKitPersistentProvider: PersistentProvider {
    static let shared: CloudKitPersistentProvider = .init(
        containerIdentifier: "iCloud.com.muijp.DropcastDev"
    )

    private let persistentContainer: LockIsolated<NSPersistentCloudKitContainer>

    private init(containerIdentifier: String) {
        persistentContainer = LockIsolated({
            let model = NSManagedObjectModel(contentsOf: Bundle.module.url(forResource: "Model", withExtension: "momd")!)!
            let container = NSPersistentCloudKitContainer(name: "Model", managedObjectModel: model)

            let storeDirectory = NSPersistentCloudKitContainer.defaultDirectoryURL()
            let storeURL = storeDirectory.appendingPathComponent("Synced.sqlite")
            let description = NSPersistentStoreDescription(url: storeURL)
            description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

            container.persistentStoreDescriptions = [description]

            container.viewContext.automaticallyMergesChangesFromParent = true

            return container
        }())

        persistentContainer.withValue { container in
            container.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("failed to load CoreData store: \(error)")
                }
            }
        }
    }

    func executeInBackground<T: Sendable>(operation: (NSManagedObjectContext) throws -> T) rethrows -> T {
        try persistentContainer.withValue { container in
            let context = container.newBackgroundContext()
            return try context.performAndWait {
                try operation(context)
            }
        }
    }
}

final class InMemoryPersistentProvider: PersistentProvider {
    private let persistentContainer: LockIsolated<NSPersistentContainer>

    init() {
        persistentContainer = LockIsolated({
            let model = NSManagedObjectModel(contentsOf: Bundle.module.url(forResource: "Model", withExtension: "momd")!)!
            let container = NSPersistentCloudKitContainer(name: "Model", managedObjectModel: model)

            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType

            container.persistentStoreDescriptions = [description]

            return container
        }())

        persistentContainer.withValue { container in
            container.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("failed to load CoreData store: \(error)")
                }
            }
        }
    }

    func executeInBackground<T: Sendable>(operation: (NSManagedObjectContext) throws -> T) rethrows -> T {
        try persistentContainer.withValue { container in
            let context = container.newBackgroundContext()
            return try context.performAndWait {
                try operation(context)
            }
        }
    }
}
