import ComposableArchitecture
import SwiftUI

public struct ShowListScreen: View {
    let store: StoreOf<ShowListReducer>

    public init(store: StoreOf<ShowListReducer>) {
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

struct ShowListScreen_Previews: PreviewProvider {
    static var previews: some View {
        ShowListScreen(
            store: StoreOf<ShowListReducer>(
                initialState: ShowListReducer.State(),
                reducer: ShowListReducer()
            )
        )
    }
}
