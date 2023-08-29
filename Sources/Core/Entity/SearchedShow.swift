import Foundation

public struct SearchedShow: Sendable, Equatable {
    public let feedURL: URL
    public let imageURL: URL
    public let title: String
    public let author: String?
    
    public init(feedURL: URL, imageURL: URL, title: String, author: String?) {
        self.feedURL = feedURL
        self.imageURL = imageURL
        self.title = title
        self.author = author
    }
}
