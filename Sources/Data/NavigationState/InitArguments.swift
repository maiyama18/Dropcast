@preconcurrency import Database
import Foundation

// TODO: objectID のみを渡して ShowDetail で Show を取得してもらった方が良い？
public struct ShowDetailInitArguments: Hashable, Sendable {
    public let showsEpisodeActionButtons: Bool
    public let feedURL: URL
    public let imageURL: URL
    public let title: String
    public let episodes: [EpisodeRecord]
    public let author: String?
    public let description: String?
    public let linkURL: URL?
    public let followed: Bool?

    public init(
        showsEpisodeActionButtons: Bool,
        feedURL: URL,
        imageURL: URL,
        title: String,
        episodes: [EpisodeRecord] = [],
        author: String? = nil,
        description: String? = nil,
        linkURL: URL? = nil,
        followed: Bool? = nil
    ) {
        self.showsEpisodeActionButtons = showsEpisodeActionButtons
        self.feedURL = feedURL
        self.imageURL = imageURL
        self.title = title
        self.episodes = episodes
        self.author = author
        self.description = description
        self.linkURL = linkURL
        self.followed = followed
    }
}
