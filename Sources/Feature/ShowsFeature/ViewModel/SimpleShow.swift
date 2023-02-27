import Entity
import Foundation

public struct SimpleShow: Equatable, Identifiable, Hashable {
    public var feedURL: URL
    public var imageURL: URL
    public var title: String
    public var author: String?

    public var id: URL { feedURL }

    public init(feedURL: URL, imageURL: URL, title: String, author: String?) {
        self.feedURL = feedURL
        self.imageURL = imageURL
        self.title = title
        self.author = author
    }

    init(iTunesShow: ITunesShow) {
        self.init(feedURL: iTunesShow.feedURL, imageURL: iTunesShow.artworkLowQualityURL, title: iTunesShow.showName, author: iTunesShow.artistName)
    }

    init(show: Entity.Show) {
        self.init(feedURL: show.feedURL, imageURL: show.imageURL, title: show.title, author: show.author)
    }
}
