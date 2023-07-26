import Dependencies
import FeedFeature
import LibraryFeature
import MessageClient
import NavigationState
import SettingsFeature
import SoundFileState
import SwiftUI

public struct MainTabScreen: View {
    @Environment(NavigationState.self) private var navigationState
    @Environment(SoundFileState.self) private var soundFileState
    
    @Dependency(\.messageClient) private var messageClient

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
        .onReceive(soundFileState.downloadErrorPublisher) { _ in
            messageClient.presentError(String(localized: "Failed to download episode", bundle: .module))
        }
    }
}
