import CoreData
import Dependencies
import Entity
import Foundation
import SwiftUI

extension ShowRecord: Model {}

extension ShowRecord {
    @MainActor
    public static func withFeedURL(_ feedURL: URL) -> FetchRequest<ShowRecord> {
        FetchRequest<ShowRecord>(
            entity: ShowRecord.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "%K == %@", #keyPath(ShowRecord.feedURL_), feedURL as CVarArg)
        )
    }
    
    @MainActor
    public static func followed() -> NSFetchRequest<ShowRecord> {
        let request = ShowRecord.fetchRequest()
        request.predicate = NSPredicate(format: "followed = %@", NSNumber(value: true))
        request.sortDescriptors = [.init(keyPath: \ShowRecord.title_, ascending: true)]
        return request
    }
    
    public var title: String { title_! }
    public var feedURL: URL { feedURL_! }
    public var imageURL: URL { imageURL_! }
    public var episodes: [EpisodeRecord] {
        guard let episodes = episodes_ as? Set<EpisodeRecord> else { return [] }
        return Array(episodes)
    }
    
    public convenience init(
        context: NSManagedObjectContext? = nil,
        title: String,
        description: String?,
        author: String?,
        feedURL: URL,
        imageURL: URL,
        linkURL: URL?
    ) {
        if let context {
            self.init(context: context)
        } else {
            self.init(entity: CloudKitPersistentProvider.shared.managedObjectModel.entitiesByName["ShowRecord"]!, insertInto: nil)
        }
        
        self.title_ = title
        self.showDescription = description
        self.author = author
        self.feedURL_ = feedURL
        self.imageURL_ = imageURL
        self.linkURL = linkURL
    }
    
    @MainActor
    public func toggleFollow() throws {
        followed = !followed
        try save()
    }
}
