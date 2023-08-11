@preconcurrency import Database
import Foundation

public struct ShowDetailInitArguments: Hashable, Sendable {
    public let feedURL: URL
    public let imageURL: URL
    public let title: String

    public init(
        feedURL: URL,
        imageURL: URL,
        title: String
    ) {
        self.feedURL = feedURL
        self.imageURL = imageURL
        self.title = title
    }
}
