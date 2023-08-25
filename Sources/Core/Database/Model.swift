import CoreData

public protocol Model {
    var viewContext: NSManagedObjectContext { get }
    @MainActor func save() throws
    @MainActor func delete() throws
}

public extension Model where Self: NSManagedObject {
    var viewContext: NSManagedObjectContext {
        PersistentProvider.cloud.viewContext
    }
    
    @MainActor
    func save() throws {
        do {
            try viewContext.save()
        } catch {
            viewContext.rollback()
            throw error
        }
    }
    
    @MainActor
    func delete() throws {
        do {
            viewContext.delete(self)
            try save()
        } catch {
            viewContext.rollback()
            throw error
        }
    }
}
