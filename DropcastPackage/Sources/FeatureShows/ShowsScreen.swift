import ComposableArchitecture
import SwiftUI

public struct ShowsScreen: View {
    let store: StoreOf<ShowsReducer>
    
    public init(store: StoreOf<ShowsReducer>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Text("Shows Screen")
                .task {
                    viewStore.send(.task)
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
