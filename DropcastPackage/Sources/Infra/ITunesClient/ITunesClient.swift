import CustomDump
import Dependencies
import Entity
import Error
import Foundation
import Logger
import Network
import XCTestDynamicOverlay

public struct ITunesClient: Sendable {
    public var searchShows: @Sendable (_ query: String) async -> Result<[ITunesShow], ITunesError>
}

extension ITunesClient {
    public static func live(urlSession: URLSession) -> ITunesClient {
        @Dependency(\.logger[.iTunes]) var logger
        
        return ITunesClient(
            searchShows: { query in
                logger.notice("searching shows by query: \(query, privacy: .public)")
                guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                      let url = URL(string: "https://itunes.apple.com/search?media=podcast&term=\(encodedQuery)") else {
                    logger.error("invalid query: \(query, privacy: .public)")
                    return .failure(ITunesError.invalidQuery)
                }

                let result = await request(session: urlSession, url: url)
                switch result {
                case .success(let data):
                    do {
                        let response = try JSONDecoder().decode(SearchShowsResponse.self, from: data)
                        let shows = response.results.compactMap { $0.toShow() }
                        logger.notice("search response:\n\(customDump(shows), privacy: .public)")
                        return .success(shows)
                    } catch {
                        logger.notice("parse error: \(error, privacy: .public)")
                        return .failure(.parseError)
                    }
                case .failure(let error):
                    logger.error("network error: \(error, privacy: .public)")
                    return .failure(.networkError(reason: error))
                }
            }
        )
    }
}

extension ITunesClient: DependencyKey {
    public static var liveValue: ITunesClient = .live(urlSession: .shared)
    public static var testValue: ITunesClient = ITunesClient(searchShows: unimplemented())
}

extension DependencyValues {
    public var iTunesClient: ITunesClient {
        get { self[ITunesClient.self] }
        set { self[ITunesClient.self] = newValue }
    }
}
