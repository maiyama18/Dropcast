import Dependencies
import ShowDetailFeature
import SwiftUI

struct ShowSearchScreen: View {
    @StateObject var viewModel: ShowSearchViewModel = .init()
    
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
                        prompt: Text("Podcast Title, Feed URL, Author...")
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
                        labelView(title: L10n.searchShows)
                    case .empty:
                        labelView(title: L10n.noResults)
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
            .navigationTitle(L10n.followShows)
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
    
    @ViewBuilder
    private func labelView(title: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle.bold())
            
            Text(title)
                .font(.title2)
        }
        .foregroundStyle(.secondary)
        .frame(maxHeight: .infinity, alignment: .center)
    }
}
