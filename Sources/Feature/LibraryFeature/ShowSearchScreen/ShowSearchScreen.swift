import NavigationState
import ShowDetailFeature
import SwiftUI

@MainActor
struct ShowSearchScreen: View {
    @State var viewModel: ShowSearchViewModel = .init()
    @Environment(NavigationState.self) private var navigationState

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
                        text: .init(
                            get: { viewModel.query },
                            set: { query in
                                Task {
                                    await viewModel.handle(action: .changeQuery(query: query))
                                }
                            }
                        ),
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
                                ShowRowView(show: SimpleShow(iTunesShow: show))
                                    .tint(.primary)
                                    .onTapGesture {
                                        Task {
                                            await viewModel.handle(action: .tapShowRow(show: show))
                                        }
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
                try await Task.sleep(for: .milliseconds(300))
                await viewModel.handle(action: .debounceQuery)
            } catch {}
        }
        .task {
            for await event in viewModel.events {
                switch event {
                case .pushShowDetail(let args):
                    navigationState.showSearchPath?.append(.showDetail(args: args))
                }
            }
        }
    }
}
