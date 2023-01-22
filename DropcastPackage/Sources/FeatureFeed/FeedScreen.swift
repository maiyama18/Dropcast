import ComposableArchitecture
import SwiftUI

public struct FeedScreen: View {
    let store: StoreOf<FeedReducer>

    public init(store: StoreOf<FeedReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Text("Feed Screen")
                .task {
                    viewStore.send(.task)
                }
        }
    }
}

struct FeedScreen_Previews: PreviewProvider {
    static var previews: some View {
        FeedScreen(
            store: StoreOf<FeedReducer>(
                initialState: FeedReducer.State(),
                reducer: FeedReducer()
            )
        )
    }
}
