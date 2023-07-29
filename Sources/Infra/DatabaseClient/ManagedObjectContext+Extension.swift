import CoreData

extension NSManagedObjectContext {
    public func saveWithErrorHandling(onError: (Error) -> Void) {
        do {
            try save()
        } catch {
            rollback()
            onError(error)
        }
    }
}
