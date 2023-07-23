import Dependencies
import Entity
import IdentifiedCollections
import ITunesClient
import NavigationState
import ShowDetailFeature
import SwiftUI

@MainActor
struct ShowSearchScreen: View {
    enum SearchState: Equatable {
        case prompt
        case empty(query: String)
        case loading(shows: IdentifiedArrayOf<ITunesShow>)
        case loaded(shows: IdentifiedArrayOf<ITunesShow>)

        var currentShows: IdentifiedArrayOf<ITunesShow> {
            switch self {
            case .prompt, .empty:
                return []
            case .loading(let shows), .loaded(let shows):
                return shows
            }
        }
        
        var searching: Bool {
            switch self {
            case .loading:
                return true
            case .prompt, .empty, .loaded:
                return false
            }
        }
    }
    
    @State private var searchState: SearchState = .prompt
    @State private var query: String = ""
    @State private var searchTask: Task<Void, Never>? = nil
    
    @Environment(NavigationState.self) private var navigationState
    
    @Dependency(\.iTunesClient) private var iTunesClient
    @Dependency(\.messageClient) private var messageClient
    @Dependency(\.rssClient) private var rssClient

    var body: some View {
        NavigationStack(
            path: .init(
                get: { navigationState.showSearchPath ?? [] },
                set: { navigationState.showSearchPath = $0 }
            )
        ) {
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    TextField(
                        "Search",
                        text: $query,
                        prompt: Text("Podcast Title, Feed URL, Author...", bundle: .module)
                    )
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.plain)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal, 12)

                Group {
                    switch searchState {
                    case .prompt:
                        ContentUnavailableView(label: {
                            Label(
                                title: { Text("Search podcasts", bundle: .module) },
                                icon: { Image(systemName: "magnifyingglass") }
                            )
                        })
                    case .empty(let query):
                        ContentUnavailableView.search(text: query)
                    case .loading(let shows), .loaded(let shows):
                        List {
                            ForEach(shows) { show in
                                NavigationLink(
                                    value: ShowSearchRoute.showDetail(
                                        args: .init(
                                            showsEpisodeActionButtons: false,
                                            feedURL: show.feedURL,
                                            imageURL: show.artworkURL,
                                            title: show.showName
                                        )
                                    )
                                ) {
                                    ShowRowView(show: SimpleShow(iTunesShow: show))
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .overlay {
                if searchState.searching {
                    ProgressView()
                        .scaleEffect(2)
                }
            }
            .navigationTitle(Text("Search", bundle: .module))
            .navigationDestination(for: ShowSearchRoute.self) { route in
                switch route {
                case .showDetail(let args):
                    ShowDetailScreen(args: args)
                }
            }
        }
        .onChange(of: query, initial: false) { _, query in
            if query.isEmpty {
                searchState = .prompt
            }
        }
        .task(id: query) {
            do {
                try await Task.sleep(for: .milliseconds(300))
                await search()
            } catch {}
        }
    }
}

private extension ShowSearchScreen {
    func search() async {
        guard !query.isEmpty else { return }
        
        searchState = .loading(shows: searchState.currentShows)
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
