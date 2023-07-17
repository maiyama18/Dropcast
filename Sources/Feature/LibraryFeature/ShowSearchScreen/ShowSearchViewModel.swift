import AsyncAlgorithms
import Dependencies
import Entity
import Foundation
import IdentifiedCollections
import ITunesClient
import MessageClient
import NavigationState
import Observation
import RSSClient

@MainActor
@Observable
final class ShowSearchViewModel {
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
        case tapShowRow(show: ITunesShow)
    }
    
    enum Event {
        case pushShowDetail(args: ShowDetailInitArguments)
    }

    @ObservationIgnored @Dependency(\.iTunesClient) private var iTunesClient
    @ObservationIgnored @Dependency(\.messageClient) private var messageClient
    @ObservationIgnored @Dependency(\.rssClient) private var rssClient

    private(set) var searchState: SearchState = .prompt
    private var searchTask: Task<Void, Never>? = nil
    private(set) var query: String = ""

    var isSearching: Bool { searchTask?.isCancelled == false }
    
    let events: AsyncChannel<Event> = .init()

    func handle(action: Action) async {
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
        case .tapShowRow(let show):
            let args = ShowDetailInitArguments(
                showsEpisodeActionButtons: false,
                feedURL: show.feedURL,
                imageURL: show.artworkURL,
                title: show.showName
            )
            await events.send(.pushShowDetail(args: args))
        }
    }
}
