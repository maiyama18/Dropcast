import CoreData
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

public struct RSSEpisode: Sendable, Equatable {
    public let id: String
    public let title: String
    public let soundURL: URL
    public let duration: TimeInterval
    public let publishedAt: Date
    public let subtitle: String?
    public let description: String?
}
