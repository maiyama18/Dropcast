import Foundation

public struct ShowDetailScreenArgs {
    public var feedURL: URL
    public var imageURL: URL
    public var title: String
    public var author: String?
    public var description: String?
    public var linkURL: URL?

    public init(feedURL: URL, imageURL: URL, title: String, author: String? = nil, description: String? = nil, linkURL: URL? = nil) {
        self.feedURL = feedURL
        self.imageURL = imageURL
        self.title = title
        self.author = author
        self.description = description
        self.linkURL = linkURL
    }
}
