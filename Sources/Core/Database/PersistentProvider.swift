@preconcurrency import CoreData
import Dependencies
import Logger
import Observation

public final class CloudKitPersistentProvider {
    // TODO: switch container identifier based on build
    public static let shared: CloudKitPersistentProvider = .init(
        containerIdentifier: "iCloud.com.muijp.DropcastDev"
    )

    private static func storeURL() -> URL {
        let storeDirectory = NSPersistentCloudKitContainer.defaultDirectoryURL()
        return storeDirectory.appendingPathComponent("Synced.sqlite")
    }

    public var viewContext: NSManagedObjectContext { persistentContainer.viewContext }
    public var managedObjectModel: NSManagedObjectModel { persistentContainer.managedObjectModel }
    
    private let persistentContainer: LockIsolated<NSPersistentCloudKitContainer>

    private init(containerIdentifier: String) {
        persistentContainer = LockIsolated({
            @Dependency(\.logger[.database]) var logger

            let model = NSManagedObjectModel(contentsOf: Bundle.module.url(forResource: "Model", withExtension: "momd")!)!
            let container = NSPersistentCloudKitContainer(name: "Model", managedObjectModel: model)

            let storeURL = Self.storeURL()
            logger.notice("store url: \(storeURL, privacy: .public)")
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
}
