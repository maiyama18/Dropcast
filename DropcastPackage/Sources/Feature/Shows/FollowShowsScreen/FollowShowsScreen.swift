import ComposableArchitecture
import SwiftUI

struct FollowShowsScreen: View {
    let store: StoreOf<FollowShowsReducer>

    @Dependency(\.continuousClock) var clock

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                ScrollView {
                    LazyVStack {
                        ForEach(viewStore.shows) { show in
                            VStack(alignment: .leading) {
                                Text(show.showName)
                                Text(show.artistName)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .navigationTitle("Search shows")
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
