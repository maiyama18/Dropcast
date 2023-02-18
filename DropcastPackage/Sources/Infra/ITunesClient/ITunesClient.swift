import Dependencies
import Entity
import Error
import Foundation
import Network
import XCTestDynamicOverlay

public struct ITunesClient: Sendable {
    public var searchShows: @Sendable (_ query: String) async throws -> [ITunesShow]
}

extension ITunesClient {
    public static func live(urlSession: URLSession) -> ITunesClient {
        ITunesClient(
            searchShows: { query in
                guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                      let url = URL(string: "https://itunes.apple.com/search?media=podcast&term=\(encodedQuery)") else {
                    throw ITunesError.invalidQuery
                }

                let result = await request(session: urlSession, url: url)
                switch result {
                case .success(let data):
                    let response = try JSONDecoder().decode(SearchShowsResponse.self, from: data)
                    return response.results.compactMap { $0.toShow() }
                case .failure(let error):
                    throw error
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
