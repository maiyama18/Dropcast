import CoreData
import Database
import Entity
import Foundation

public struct RSSShow: Sendable, Equatable {
    public let feedURL: URL
    public let title: String
    public let imageURL: URL
    public let description: String?
    public let author: String?
    public let linkURL: URL?
    
    public let episodes: [RSSEpisode]
}

public extension RSSShow {
    func toModel(context: NSManagedObjectContext) -> ShowRecord {
        let show = ShowRecord(
            context: context,
            title: title,
            description: description,
            author: author,
            feedURL: feedURL,
            imageURL: imageURL,
            linkURL: linkURL
        )
        
        for episode in episodes {
            show.addToEpisodes_(episode.toModel(context: context))
        }
        
        return show
    }
}

public struct RSSEpisode: Sendable, Equatable {
    public let id: String
    public let title: String
    public let soundURL: URL
    public let duration: TimeInterval
    public let publishedAt: Date
    public let subtitle: String?
    public let description: String?
}

public extension RSSEpisode {
    func toModel(context: NSManagedObjectContext) -> EpisodeRecord {
        EpisodeRecord(
            context: context,
            id: id,
            title: title,
            subtitle: subtitle,
            description: description,
            duration: duration,
            soundURL: soundURL,
            publishedAt: publishedAt
        )
    }
}
