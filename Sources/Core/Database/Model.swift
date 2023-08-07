import CoreData

public protocol Model {
    @MainActor func save() throws
    @MainActor func delete() throws
}

public extension Model where Self: NSManagedObject {
    @MainActor
    func save() throws {
        let context = CloudKitPersistentProvider.shared.viewContext
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
    
    @MainActor
    func delete() throws {
        let context = CloudKitPersistentProvider.shared.viewContext
        do {
            context.delete(self)
            try save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
