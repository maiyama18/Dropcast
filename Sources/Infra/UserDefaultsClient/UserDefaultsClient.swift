import Build
import Defaults
import Dependencies
import Foundation

// > The UserDefaults class is thread-safe.
// ref: https://developer.apple.com/documentation/foundation/userdefaults
extension UserDefaults: @unchecked Sendable {}

extension Defaults.Keys {
    static let feedRefreshedAt = Key<Date?>("feedRefreshedAt")
    static let storedSoundPlayerState = Key<StoredSoundPlayerState?>("storedSoundPlayerState")
}

public struct UserDefaultsClient: Sendable {
    public var getFeedRefreshedAt: @Sendable () -> Date?
    public var setFeedRefreshedAt: @Sendable (Date) -> Void
    public var getStoredSoundPlayerState: @Sendable () -> StoredSoundPlayerState?
    public var setStoredSoundPlayerState: @Sendable (String, TimeInterval) -> Void
}

extension UserDefaultsClient {
    public static func instance(userDefaults: UserDefaults) -> UserDefaultsClient {
        .init(
            getFeedRefreshedAt: { userDefaults[.feedRefreshedAt] },
            setFeedRefreshedAt: { userDefaults[.feedRefreshedAt] = $0 },
            getStoredSoundPlayerState: { userDefaults[.storedSoundPlayerState] },
            setStoredSoundPlayerState: { userDefaults[.storedSoundPlayerState] = .init(episodeID: $0, currentTime: $1) }
        )
    }
}

extension UserDefaultsClient: DependencyKey {
    public static let liveValue: UserDefaultsClient = .instance(userDefaults: UserDefaults(suiteName: InfoPlist.appGroupID)!)
    public static let testValue: UserDefaultsClient = .init(
        getFeedRefreshedAt: unimplemented(),
        setFeedRefreshedAt: { _ in unimplemented() },
        getStoredSoundPlayerState: unimplemented(),
        setStoredSoundPlayerState: { _, _ in unimplemented() }
    )
}

extension DependencyValues {
    public var userDefaultsClient: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}
