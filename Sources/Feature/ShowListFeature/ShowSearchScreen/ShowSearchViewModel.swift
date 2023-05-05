import Combine
import Dependencies
import Foundation
import IdentifiedCollections

@MainActor
final class ShowSearchViewModel: ObservableObject {
    enum SearchState: Equatable {
        case prompt
        case empty
        case loaded(shows: IdentifiedArrayOf<SimpleShow>)

        var currentShows: IdentifiedArrayOf<SimpleShow> {
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
        case tapShowRow
    }
    
    enum Event {
    }
    
    @Dependency(\.iTunesClient) private var iTunesClient
    @Dependency(\.messageClient) private var messageClient
    @Dependency(\.rssClient) private var rssClient
    
    @Published private(set) var searchState: SearchState = .prompt
    @Published private var searchTask: Task<Void, Never>? = nil
    @Published private(set) var query: String = ""
    
    var isSearching: Bool { searchTask?.isCancelled == false }
    
    var eventStream: AsyncStream<Event> { eventSubject.eraseToStream() }
    private let eventSubject: PassthroughSubject<Event, Never> = .init()
    
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
                        searchState = .loaded(shows: [SimpleShow(show: show)])
                    case .failure:
                        searchState = .empty
                    }
                } else {
                    switch await self.iTunesClient.searchShows(query) {
                    case .success(let shows):
                        searchState = shows.isEmpty
                        ? .empty
                        : .loaded(shows: .init(uniqueElements: shows.uniqued(on: \.feedURL).map { SimpleShow(iTunesShow: $0) }))
                    case .failure(let error):
                        let message: String
                        switch error {
                        case .parseError:
                            message = L10n.Error.invalidServerResponse
                        case .invalidQuery:
                            message = L10n.Error.invalidQuery
                        case .networkError(reason: let error):
                            message = error.localizedDescription
                        }
                        
                        messageClient.presentError(message)
                    }
                }
            }
        case .tapShowRow:
            print("TODO")
        }
    }
}
