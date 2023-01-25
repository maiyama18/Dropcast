import ComposableArchitecture
import SwiftUI

struct FollowShowsScreen: View {
    let store: StoreOf<FollowShowsReducer>

    @Dependency(\.continuousClock) var clock

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                Group {
                    switch viewStore.shows {
                    case .empty:
                        VStack {
                            Image(systemName: "magnifyingglass")
                                .font(.largeTitle)

                            Text("No Results")
                                .font(.title2)
                        }
                        .frame(maxHeight: .infinity, alignment: .center)
                    case .present(let shows):
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(shows) { show in
                                    ShowRowView(show: show)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Search shows")
                .navigationBarTitleDisplayMode(.inline)
                .searchable(
                    text: viewStore.binding(get: \.query, send: { .queryChanged(query: $0) }),
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: Text("Show name, Host ...")
                )
            }
            .task(id: viewStore.query) {
                do {
                    try await clock.sleep(for: .milliseconds(300))
                    viewStore.send(.queryChangeDebounced)
                } catch {}
            }
        }
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
    }
}
