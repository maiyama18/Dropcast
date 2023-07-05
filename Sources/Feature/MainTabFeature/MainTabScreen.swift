import Dependencies
import FeedFeature
import ScreenTransitionCoordinator
import SettingsFeature
import ShowListFeature
import SwiftUI

enum Tab: Int {
    case feed
    case showList
    case settings
}

public struct MainTabScreen: View {
    @State private var tab: Tab = .feed
    
    @Dependency(\.screenTransitionCoordinator) private var coordinator

    public init() {}
    
    public var body: some View {
        TabView(selection: $tab) {
            FeedScreen()
                .tabItem { Label(L10n.feed, systemImage: "dot.radiowaves.up.forward") }
                .tag(Tab.feed)
            
            ShowListScreen()
                .tabItem { Label(L10n.shows, systemImage: "square.stack.3d.down.right") }
                .tag(Tab.showList)
            
            SettingsScreen()
                .tabItem { Label(L10n.settings, systemImage: "gearshape") }
                .tag(Tab.settings)
        }
        .task {
            for await _ in coordinator.changeTabToShows {
                tab = .showList
            }
        }
    }
}
