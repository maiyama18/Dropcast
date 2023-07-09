import Combine
import Dependencies
import Entity
import Foundation
import IdentifiedCollections
import ITunesClient
import MessageClient
import RSSClient

@MainActor
final class ShowSearchViewModel: ObservableObject {
    enum SearchState: Equatable {
        case prompt
        case empty(query: String)
        case loaded(shows: IdentifiedArrayOf<ITunesShow>)

        var currentShows: IdentifiedArrayOf<ITunesShow> {
            switch self {
            case .prompt, .empty:
                return []
            case .loaded(let shows):
                return shows
            }
        }
    }

    enum Action {
        case changeQuery(query: String)
        case debounceQuery
    }

    @Dependency(\.iTunesClient) private var iTunesClient
    @Dependency(\.messageClient) private var messageClient
    @Dependency(\.rssClient) private var rssClient

    @Published var path: [ShowSearchRoute] = []
    @Published private(set) var searchState: SearchState = .prompt
    @Published private var searchTask: Task<Void, Never>? = nil
    @Published private(set) var query: String = ""

    var isSearching: Bool { searchTask?.isCancelled == false }

    func handle(action: Action) {
        switch action {
        case .changeQuery(query: let query):
            self.query = query

            if query.isEmpty {
                searchTask?.cancel()
                self.searchState = .prompt
            }
        case .debounceQuery:
            guard !query.isEmpty else { return }

            searchTask = Task {
                defer { searchTask = nil }

                if let url = URL(string: query), (url.scheme == "https" || url.scheme == "http") {
                    switch await rssClient.fetch(url) {
                    case .success(let show):
                        searchState = .loaded(shows: [ITunesShow(show: show)])
                    case .failure:
                        searchState = .empty(query: query)
                    }
                } else {
                    switch await self.iTunesClient.searchShows(query) {
                    case .success(let shows):
                        searchState = shows.isEmpty
                            ? .empty(query: query)
                            : .loaded(shows: .init(uniqueElements: shows.uniqued(on: \.feedURL)))
                    case .failure(let error):
                        let message: String
                        switch error {
                        case .parseError:
                            message = String(localized: "Invalid server response", bundle: .module)
                        case .invalidQuery:
                            message = String(localized: "Invalid query", bundle: .module)
                        case .networkError(reason: let error):
                            message = error.localizedDescription
                        }

                        messageClient.presentError(message)
                    }
                }
            }
        }
    }
}
