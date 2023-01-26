import Foundation

public struct Show {
    public var title: String
    public var description: String?
    public var author: String?
    public var imageURL: URL
    public var linkURL: URL?
    public var episodes: [Episode]

    public init(
        title: String,
        description: String?,
        author: String?,
        imageURL: URL,
        linkURL: URL?,
        episodes: [Episode]
    ) {
        self.title = title
        self.description = description
        self.author = author
        self.imageURL = imageURL
        self.linkURL = linkURL
        self.episodes = episodes
    }
}
