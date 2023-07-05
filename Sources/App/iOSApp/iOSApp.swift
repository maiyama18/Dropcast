import DebugFeature
import DeepLink
import Dependencies
import MainTabFeature
import ScreenTransitionCoordinator
import SwiftUI

public struct IOSApp: App {
    @Dependency(\.screenTransitionCoordinator) private var coordinator
    
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            MainTabScreen()
                .onAppear {
                    #if DEBUG
                    installDebugMenu()
                    #endif
                }
                .onOpenURL { url in
                    Task {
                        switch url {
                        case DeepLink.showSearch:
                            await coordinator.changeTabToLibrary.send(())
                            await coordinator.openShowSearch.send(())
                        default:
                            break
                        }
                    }
                }
        }
    }
}
