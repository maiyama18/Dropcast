import FeedFeature
import SettingsFeature
import ShowListFeature
import SwiftUI

public struct MainTabScreen: View {
    public init() {}
    
    public var body: some View {
        TabView {
            FeedScreen()
                .tabItem { Label(L10n.feed, systemImage: "dot.radiowaves.up.forward") }
            
            ShowListScreen()
                .tabItem { Label(L10n.shows, systemImage: "square.stack.3d.down.right") }
            
            SettingsScreen()
                .tabItem { Label(L10n.settings, systemImage: "gearshape") }
        }
    }
}
