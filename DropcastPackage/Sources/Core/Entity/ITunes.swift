import Foundation

public struct Show: Sendable {
    public var id: Int
    public var artistName: String
    public var showName: String
    public var genreName: String
    public var feedURL: URL
    public var storeURL: URL
    public var artworkURL: URL

    public init(
        id: Int,
        artistName: String,
        showName: String,
        genreName: String,
        feedURL: URL,
        storeURL: URL,
        artworkURL: URL
    ) {
        self.id = id
        self.artistName = artistName
        self.showName = showName
        self.genreName = genreName
        self.feedURL = feedURL
        self.storeURL = storeURL
        self.artworkURL = artworkURL
    }
}
