import CoreData

public protocol Model {
    var viewContext: NSManagedObjectContext { get }
    @MainActor func saveModel() throws
    @MainActor func deleteModel() throws
}

public extension Model where Self: NSManagedObject {
    var viewContext: NSManagedObjectContext {
        PersistentProvider.cloud.viewContext
    }
    
    @MainActor
    func saveModel() throws {
        do {
            try viewContext.save()
        } catch {
            viewContext.rollback()
            throw error
        }
    }
    
    @MainActor
    func deleteModel() throws {
        do {
            viewContext.delete(self)
            try saveModel()
        } catch {
            viewContext.rollback()
            throw error
        }
    }
}
