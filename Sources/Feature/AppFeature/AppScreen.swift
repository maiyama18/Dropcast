import ComposableArchitecture
import FeedFeature
import SettingsFeature
import ShowsFeature
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
                            Label(L10n.feed, systemImage: "dot.radiowaves.up.forward")
                        }

                    ShowListScreen(store: store.scope(state: \.showsState, action: { .shows($0) }))
                        .tag(AppReducer.Tab.shows)
                        .tabItem {
                            Label(L10n.shows, systemImage: "square.stack.3d.down.right")
                        }

                    SettingsScreen(store: store.scope(state: \.settingsState, action: { .settings($0) }))
                        .tag(AppReducer.Tab.settings)
                        .tabItem {
                            Label(L10n.settings, systemImage: "gearshape")
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
