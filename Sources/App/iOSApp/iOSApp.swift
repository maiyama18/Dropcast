import Database
import DebugFeature
import DeepLink
import Dependencies
import MainTabFeature
import NavigationState
import SoundFileState
import SoundPlayerState
import SwiftUI

public struct IOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    private let navigationState: NavigationState = .shared
    private let soundFileState: SoundFileState = .shared
    private let soundPlayerState: SoundPlayerState = .shared
    private let persistentContainer: PersistentProvider = .cloud

    @Dependency(\.logger[.app]) private var logger
    @Dependency(\.duplicatedRecordsDeleteUseCase) private var duplicatedRecordsDeleteUseCase

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
                .onAppear {
                    do {
                        try duplicatedRecordsDeleteUseCase.delete()
                    } catch {
                        logger.error("failed to delete duplicated records: \(error, privacy: .public)")
                    }
                }
        }
    }
}
