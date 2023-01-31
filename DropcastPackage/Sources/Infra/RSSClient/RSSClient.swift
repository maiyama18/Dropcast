import Dependencies
import Entity
import Error
import FeedKit
import Foundation

public struct RSSClient: Sendable {
    public var fetch: @Sendable (_ url: URL) async throws -> Show
}

extension RSSClient {
    static func live(urlSession: URLSession = .shared) -> RSSClient {
        RSSClient(
            fetch: { url in
                let (data, _) = try await urlSession.data(from: url)
                let parser = FeedParser(data: data)
                let rssFeed = try await parser.parseRSS()

                guard let show = rssFeed.toShow(feedURL: url) else {
                    throw RSSError.invalidFeed
                }
                return show
            }
        )
    }
}

extension RSSClient: DependencyKey {
    public static let liveValue: RSSClient = .live(urlSession: .shared)
    public static var testValue: RSSClient = RSSClient(
        fetch: unimplemented()
    )
}

extension DependencyValues {
    public var rssClient: RSSClient {
        get { self[RSSClient.self] }
        set { self[RSSClient.self] = newValue }
    }
}
