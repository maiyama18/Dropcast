import ComposableArchitecture
import FeatureFeed
import FeatureShows
import SwiftUI

public struct AppScreen: View {
    let store: StoreOf<AppReducer> = .init(initialState: AppReducer.State(), reducer: AppReducer())

    public var body: some View {
        WithViewStore(store, observe: \.activeTab) { viewStore in
            TabView(selection: viewStore.binding(get: { $0 }, send: { .activeTabChanged($0) })) {
                Group {
                    FeedScreen(store: store.scope(state: \.feedState, action: { .feed($0) }))
                        .tag(AppReducer.Tab.feed)
                        .tabItem {
                            Label("Feed", systemImage: "dot.radiowaves.up.forward")
                        }

                    ShowsScreen(store: store.scope(state: \.showsState, action: { .shows($0) }))
                        .tag(AppReducer.Tab.shows)
                        .tabItem {
                            Label("Shows", systemImage: "square.stack.3d.down.right")
                        }
                }
                .toolbarBackground(.visible, for: .tabBar)
            }
        }
    }

    public init() {}
}

struct AppScreen_Previews: PreviewProvider {
    static var previews: some View {
        AppScreen()
    }
}
