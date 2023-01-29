import Error
import FeedKit
import Foundation

extension FeedParser {
    func parseRSS() async throws -> RSSFeed {
        try await withCheckedThrowingContinuation { continuation in
            parseAsync { result in
                switch result {
                case .success(let feed):
                    guard case .rss(let rssFeed) = feed else {
                        continuation.resume(throwing: RSSError.invalidFeed)
                        return
                    }
                    continuation.resume(returning: rssFeed)
                case .failure:
                    continuation.resume(throwing: RSSError.fetchError)
                }
            }
        }
    }
}
