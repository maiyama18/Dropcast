import Algorithms
import Dependencies
import Entity
import Foundation
import ITunesClient
import RSSClient

public struct ShowSearchUseCase: Sendable {
    public var search: @Sendable (_ query: String) async throws -> [SearchedShow]
}

extension ShowSearchUseCase {
    static var live: ShowSearchUseCase {
        @Dependency(\.iTunesClient) var iTunesClient
        @Dependency(\.rssClient) var rssClient
        
        return ShowSearchUseCase(
            search: { query in
                guard !query.isEmpty else { return [] }
                
                if let url = URL(string: query), (url.scheme == "https" || url.scheme == "http") {
                    do {
                        let rssShow = try await rssClient.fetch(url).get()
                        return [
                            SearchedShow(
                                feedURL: rssShow.feedURL,
                                imageURL: rssShow.imageURL,
                                title: rssShow.title,
                                author: rssShow.author
                            ),
                        ]
                    } catch {
                        return []
                    }
                } else {
                    let iTunesShows = try await iTunesClient.searchShows(query).get()
                    return iTunesShows.uniqued(on: \.feedURL).map { iTunesShow in
                        SearchedShow(
                            feedURL: iTunesShow.feedURL,
                            imageURL: iTunesShow.artworkURL,
                            title: iTunesShow.showName,
                            author: iTunesShow.artistName
                        )
                    }
                }
            }
        )
    }
}

extension ShowSearchUseCase: DependencyKey {
    public static var liveValue: ShowSearchUseCase = .live
    public static var testValue: ShowSearchUseCase = ShowSearchUseCase(search: unimplemented())
}

extension DependencyValues {
    public var showSearchUseCase: ShowSearchUseCase {
        get { self[ShowSearchUseCase.self] }
        set { self[ShowSearchUseCase.self] = newValue }
    }
}
