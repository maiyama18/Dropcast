import DatabaseClient
import DebugFeature
import DeepLink
import Dependencies
import MainTabFeature
import NavigationState
import SoundFileState
import SoundPlayerState
import SwiftUI

public struct IOSApp: App {
    private let navigationState: NavigationState = .shared
    private let soundFileState: SoundFileState = .shared
    private let soundPlayerState: SoundPlayerState = .shared
    private let persistentContainer: CloudKitPersistentProvider = .shared

    public init() {}

    public var body: some Scene {
        WindowGroup {
            MainTabScreen()
                .installDebugMenu()
                .environment(navigationState)
                .environment(soundFileState)
                .environment(soundPlayerState)
                .environment(\.managedObjectContext, persistentContainer.viewContext)
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
