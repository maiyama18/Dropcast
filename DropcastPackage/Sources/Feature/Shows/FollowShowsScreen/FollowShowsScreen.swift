import ComposableArchitecture
import ShowDetailFeature
import SwiftUI

struct FollowShowsScreen: View {
    let store: StoreOf<FollowShowsReducer>

    @Dependency(\.continuousClock) private var clock

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                Group {
                    switch viewStore.showsState {
                    case .prompt:
                        labelView(title: "Search Shows")
                    case .empty:
                        labelView(title: "No Results")
                    case .loaded(let shows):
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(shows) { show in
                                    NavigationLink(
                                        destination: IfLetStore(
                                            self.store.scope(
                                                state: \.selectedShowState?.value,
                                                action: { .showDetail($0) }
                                            )
                                        ) {
                                            ShowDetailScreen(store: $0)
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
                            .padding(.horizontal)
                        }
                    }
                }
                .overlay {
                    if viewStore.searchRequestInFlight {
                        ProgressView()
                            .scaleEffect(2)
                    }
                }
                .navigationTitle("Follow shows")
                .searchable(
                    text: viewStore.binding(get: \.query, send: { .queryChanged(query: $0) }),
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: Text("Show title, Feed URL, Author...")
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

struct FollowShowsScreen_Previews: PreviewProvider {
    static var previews: some View {
        FollowShowsScreen(
            store: StoreOf<FollowShowsReducer>(
                initialState: FollowShowsReducer.State(),
                reducer: FollowShowsReducer()
            )
        )
        .tint(.orange)
    }
}
