import Dependencies
import Extension
import FeedFeature
import LibraryFeature
import MessageClient
import NavigationState
import PlayerFeature
import SettingsFeature
import SoundFileState
import SoundPlayerState
import SwiftUI

import NukeUI

public struct MainTabScreen: View {
    @Environment(NavigationState.self) private var navigationState
    @Environment(SoundFileState.self) private var soundFileState

    @Dependency(\.messageClient) private var messageClient

    @State private var playerBannerHeight: Double = 0

    public init() {}

    public var body: some View {
        TabView(selection: .init(get: { navigationState.mainTab }, set: { navigationState.mainTab = $0 })) {
            Group {
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
            .toolbarBackground(.ultraThinMaterial, for: .tabBar)
            .player()
        }
        .onReceive(soundFileState.downloadErrorPublisher) { _ in
            messageClient.presentError(String(localized: "Failed to download episode", bundle: .module))
        }
        .onPreferenceChange(PlayerBannerHeightKey.self) { height in
            playerBannerHeight = height
        }
        .environment(\.playerBannerHeight, playerBannerHeight)
    }
}
