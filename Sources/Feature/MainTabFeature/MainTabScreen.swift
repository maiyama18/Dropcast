import Dependencies
import FeedFeature
import LibraryFeature
import ScreenTransitionCoordinator
import SettingsFeature
import SwiftUI

enum Tab: Int {
    case feed
    case library
    case settings
}

public struct MainTabScreen: View {
    @State private var tab: Tab = .feed

    @Dependency(\.screenTransitionCoordinator) private var coordinator

    public init() {}

    public var body: some View {
        TabView(selection: $tab) {
            FeedScreen()
                .tabItem {
                    Label(title: { Text("Feed", bundle: .module) }, icon: { Image(systemName: "dot.radiowaves.up.forward") })
                }
                .tag(Tab.feed)

            ShowListScreen()
                .tabItem {
                    Label(title: { Text("Library", bundle: .module) }, icon: { Image(systemName: "square.stack.3d.down.right") })
                }
                .tag(Tab.library)

            SettingsScreen()
                .tabItem {
                    Label(title: { Text("Settings", bundle: .module) }, icon: { Image(systemName: "gearshape") })
                }
                .tag(Tab.settings)
        }
        .task {
            for await _ in coordinator.changeTabToLibrary {
                tab = .library
            }
        }
    }
}
