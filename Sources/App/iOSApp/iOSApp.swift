import DebugFeature
import DeepLink
import Dependencies
import MainTabFeature
import NavigationState
import SwiftUI

public struct IOSApp: App {
    private let navigationState: NavigationState = .shared

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
