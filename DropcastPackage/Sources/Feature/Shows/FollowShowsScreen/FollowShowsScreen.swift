import ComposableArchitecture
import SwiftUI

struct FollowShowsScreen: View {
    let store: StoreOf<FollowShowsReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                Text("Query: " + viewStore.query)
                    .navigationTitle("Search shows")
                    .searchable(
                        text: viewStore.binding(get: \.query, send: { .queryChanged(query: $0) }),
                        prompt: Text("Title, Host ...")
                    )
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
