import Dependencies
import Entity
import Error
import FeedKit
import Foundation
import Logger
import Network

public struct RSSClient: Sendable {
    public var fetch: @Sendable (_ url: URL) async -> Result<Show, RSSError>
}

extension RSSClient {
    static func live(urlSession: URLSession = .shared) -> RSSClient {
        @Dependency(\.logger[.rss]) var logger
        
        return RSSClient(
            fetch: { url in
                logger.notice("fetching rss: \(url, privacy: .public)")
                
                let result = await request(session: urlSession, url: url)
                
                let data: Data
                switch result {
                case .success(let tmpData):
                    data = tmpData
                case .failure:
                    return .failure(.invalidFeed)
                }
                
                let parser = FeedParser(data: data)
                
                let rssFeed: RSSFeed
                do {
                    rssFeed = try await parser.parseRSS()
                } catch {
                    logger.fault("failed to parse rss feed: \(error)")
                    return .failure(.invalidFeed)
                }
                
                guard let show = rssFeed.toShow(feedURL: url) else {
                    logger.fault("failed to convert to show")
                    return .failure(RSSError.invalidFeed)
                }
                logger.notice("fetching rss succeeded:\n\(customDump(show), privacy: .public)")
                return .success(show)
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
