import Dependencies
import FeedFeature
import LibraryFeature
import NavigationState
import SettingsFeature
import SwiftUI

public struct MainTabScreen: View {
    @Environment(NavigationState.self) private var navigationState

    public init() {}

    public var body: some View {
        TabView(selection: .init(get: { navigationState.mainTab }, set: { navigationState.mainTab = $0 })) {
            FeedScreen()
                .tabItem {
                    Label(title: { Text("Feed", bundle: .module) }, icon: { Image(systemName: "dot.radiowaves.up.forward") })
                }
                .tag(MainTab.feed)

            ShowListScreen()
                .tabItem {
                    Label(title: { Text("Library", bundle: .module) }, icon: { Image(systemName: "square.stack.3d.down.right") })
                }
                .tag(MainTab.library)

            SettingsScreen()
                .tabItem {
                    Label(title: { Text("Settings", bundle: .module) }, icon: { Image(systemName: "gearshape") })
                }
                .tag(MainTab.settings)
        }
    }
}
