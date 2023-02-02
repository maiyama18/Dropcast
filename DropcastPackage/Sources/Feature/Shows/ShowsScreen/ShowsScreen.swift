import ComposableArchitecture
import SwiftUI

public struct ShowsScreen: View {
    let store: StoreOf<ShowsReducer>

    public init(store: StoreOf<ShowsReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                Text("Shows Screen")
                    .task {
                        viewStore.send(.task)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                viewStore.send(.openFollowShowsButtonTapped)
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
            }
            .sheet(
                isPresented: viewStore.binding(
                    get: \.followShowsPresented,
                    send: { _ in .followShowsDismissed }
                )
            ) {
                IfLetStore(store.scope(state: \.followShowsState, action: { .followShows($0) })) {
                    ShowSearchScreen(store: $0)
                }
            }
        }
    }
}

struct ShowsScreen_Previews: PreviewProvider {
    static var previews: some View {
        ShowsScreen(
            store: StoreOf<ShowsReducer>(
                initialState: ShowsReducer.State(),
                reducer: ShowsReducer()
            )
        )
    }
}
