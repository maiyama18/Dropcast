import ComposableArchitecture
import ShowDetailFeature
import SwiftUI

struct ShowSearchScreen: View {
    let store: StoreOf<ShowSearchReducer>

    @Dependency(\.continuousClock) private var clock

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                Group {
                    switch viewStore.showsState {
                    case .prompt:
                        labelView(title: L10n.searchShows)
                    case .empty:
                        labelView(title: L10n.noResults)
                    case .loaded(let shows):
                        List {
                            ForEach(shows) { show in
                                NavigationLink(
                                    destination: IfLetStore(
                                        self.store.scope(
                                            state: \.selectedShowState?.value,
                                            action: { .showDetail($0) }
                                        )
                                    ) {
                                        ShowDetailScreen(store: $0, showsEpisodePlayButtons: false)
                                    },
                                    tag: show.feedURL,
                                    selection: viewStore.binding(
                                        get: \.selectedShowState?.id,
                                        send: { .showDetailSelected(feedURL: $0) }
                                    )
                                ) {
                                    ShowRowView(show: show)
                                }
                                .tint(.primary)
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .overlay {
                    if viewStore.searchRequestInFlight {
                        ProgressView()
                            .scaleEffect(2)
                    }
                }
                .navigationTitle(L10n.followShows)
                .searchable(
                    text: viewStore.binding(get: \.query, send: { .queryChanged(query: $0) }),
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: Text(L10n.searchPlaceholder)
                )
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
            }
            .task(id: viewStore.query) {
                do {
                    try await clock.sleep(for: .milliseconds(300))
                    viewStore.send(.queryChangeDebounced)
                } catch {}
            }
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

struct ShowSearchScreen_Previews: PreviewProvider {
    static var previews: some View {
        ShowSearchScreen(
            store: StoreOf<ShowSearchReducer>(
                initialState: ShowSearchReducer.State(),
                reducer: ShowSearchReducer()
            )
        )
        .tint(.orange)
    }
}
