import Algorithms
import Database
import Dependencies
import Entity
import IdentifiedCollections
import ITunesClient
import NavigationState
import ShowDetailFeature
import ShowSearchUseCase
import SwiftUI

@MainActor
struct ShowSearchScreen: View {
    enum SearchState: Equatable {
        case prompt
        case empty(query: String)
        case loading(shows: [SearchedShow])
        case loaded(shows: [SearchedShow])

        var currentShows: [SearchedShow] {
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
    
    @Dependency(\.messageClient) private var messageClient
    @Dependency(\.showSearchUseCase) private var showSearchUseCase

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
                            ForEach(shows, id: \.feedURL) { show in
                                NavigationLink(
                                    value: ShowSearchRoute.showDetail(
                                        args: .init(
                                            feedURL: show.feedURL,
                                            imageURL: show.imageURL,
                                            title: show.title
                                        )
                                    )
                                ) {
                                    ShowRowView(feedURL: show.feedURL, imageURL: show.imageURL, title: show.title, author: show.author)
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
                        .padding(8)
                        .background(Material.ultraThin, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
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
        guard !query.isEmpty else {
            searchState = .prompt
            return
        }
        
        searchState = .loading(shows: searchState.currentShows)
        do {
            let shows = try await showSearchUseCase.search(query)
            if shows.isEmpty {
                searchState = .empty(query: query)
            } else {
                searchState = .loaded(shows: shows)
            }
        } catch {
            if !Task.isCancelled {
                messageClient.presentError(String(localized: "Unexpected error occurred", bundle: .module))
            }
        }
    }
}
