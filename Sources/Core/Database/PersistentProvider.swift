@preconcurrency import CoreData
import Dependencies
import Logger
import Observation

public final class PersistentProvider {
    // TODO: switch container identifier based on build
    public static let cloud: PersistentProvider = .init(
        persistentContainer: makePersistentCloudKitContainer(containerIdentifier: "iCloud.com.muijp.DropcastDev")
    )
    
    public static let inMemory: PersistentProvider = .init(
        persistentContainer: {
            let model = NSManagedObjectModel(contentsOf: Bundle.module.url(forResource: "Model", withExtension: "momd")!)!
            let container = NSPersistentCloudKitContainer(name: "Model", managedObjectModel: model)
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))]
            return container
        }()
    )
    
    private static func storeURL() -> URL {
        let storeDirectory = NSPersistentCloudKitContainer.defaultDirectoryURL()
        return storeDirectory.appendingPathComponent("Synced.sqlite")
    }
    
    private static func makePersistentCloudKitContainer(containerIdentifier: String) -> NSPersistentContainer {
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
    }
    
    public var viewContext: NSManagedObjectContext { persistentContainer.viewContext }
    public var managedObjectModel: NSManagedObjectModel { persistentContainer.managedObjectModel }
    
    private let persistentContainer: LockIsolated<NSPersistentContainer>
    
    private init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = LockIsolated(persistentContainer)
        self.persistentContainer.withValue { container in
            container.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("failed to load CoreData store: \(error)")
                }
            }
        }
    }
}
