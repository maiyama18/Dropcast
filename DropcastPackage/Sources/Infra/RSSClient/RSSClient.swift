import Entity
import Error
import FeedKit
import Foundation

public struct RSSClient {
    public var fetch: (_ url: URL) async throws -> Show
}

extension RSSClient {
    static func live(urlSession: URLSession = .shared) -> RSSClient {
        RSSClient(
            fetch: { url in
                let (data, _) = try await urlSession.data(from: url)
                let parser = FeedParser(data: data)
                let rssFeed = try await parser.parseRSS()

                guard let show = rssFeed.toShow() else {
                    throw RSSError.invalidFeed
                }
                return show
            }
        )
    }
}
