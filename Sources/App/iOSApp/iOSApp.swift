import DebugFeature
import DeepLink
import Dependencies
import MainTabFeature
import NavigationState
import SoundFileState
import SwiftUI

public struct IOSApp: App {
    private let navigationState: NavigationState = .shared
    private let soundFileState: SoundFileState = .shared

    public init() {}

    public var body: some Scene {
        WindowGroup {
            MainTabScreen()
                .onAppear {
                    #if DEBUG
                    installDebugMenu()
                    #endif
                }
                .environment(navigationState)
                .environment(soundFileState)
                .onOpenURL { url in
                    Task {
                        switch url {
                        case DeepLink.showSearch:
                            navigationState.mainTab = .library
                            navigationState.showSearchPath = []
                        default:
                            break
                        }
                    }
                }
        }
    }
}
