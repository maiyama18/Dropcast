import Dependencies
import ShowDetailFeature
import SwiftUI

@MainActor
struct ShowSearchScreen: View {
    @State var viewModel: ShowSearchViewModel = .init()

    @Dependency(\.continuousClock) private var clock

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    TextField(
                        "Search",
                        text: .init(get: { viewModel.query }, set: { viewModel.handle(action: .changeQuery(query: $0)) }),
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
                    switch viewModel.searchState {
                    case .prompt:
                        ContentUnavailableView(label: {
                            Label(
                                title: { Text("Search podcasts", bundle: .module) },
                                icon: { Image(systemName: "magnifyingglass") }
                            )
                        })
                    case .empty(let query):
                        ContentUnavailableView.search(text: query)
                    case .loaded(let shows):
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
                                        .tint(.primary)
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .overlay {
                if viewModel.isSearching {
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
        .task(id: viewModel.query) {
            do {
                try await clock.sleep(for: .milliseconds(300))
                viewModel.handle(action: .debounceQuery)
            } catch {}
        }
    }
}
