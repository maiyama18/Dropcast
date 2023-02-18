import Dependencies
import Entity
import Error
import FeedKit
import Foundation
import Logger

public struct RSSClient: Sendable {
    public var fetch: @Sendable (_ url: URL) async throws -> Show
}

extension RSSClient {
    static func live(urlSession: URLSession = .shared) -> RSSClient {
        @Dependency(\.logger[.rss]) var logger
        
        return RSSClient(
            fetch: { url in
                logger.notice("fetching rss: \(url, privacy: .public)")
                
                let (data, _) = try await urlSession.data(from: url)
                let parser = FeedParser(data: data)
                let rssFeed = try await parser.parseRSS()

                guard let show = rssFeed.toShow(feedURL: url) else {
                    throw RSSError.invalidFeed
                }
                logger.notice("fetching rss succeeded:\n\(customDump(show), privacy: .public)")
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
