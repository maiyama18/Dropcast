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
    static let soundPlayerSpeedRate = Key<Float?>("soundPlayerSpeedRate")
}

public struct UserDefaultsClient: Sendable {
    public var getFeedRefreshedAt: @Sendable () -> Date?
    public var setFeedRefreshedAt: @Sendable (Date) -> Void
    public var getStoredSoundPlayerState: @Sendable () -> StoredSoundPlayerState?
    public var setStoredSoundPlayerState: @Sendable (String, TimeInterval) -> Void
    public var getSoundPlayerSpeedRate: @Sendable () -> Float?
    public var setSoundPlayerSpeedRate: @Sendable (Float) -> Void
}

extension UserDefaultsClient {
    public static func instance(userDefaults: UserDefaults) -> UserDefaultsClient {
        .init(
            getFeedRefreshedAt: { userDefaults[.feedRefreshedAt] },
            setFeedRefreshedAt: { userDefaults[.feedRefreshedAt] = $0 },
            getStoredSoundPlayerState: { userDefaults[.storedSoundPlayerState] },
            setStoredSoundPlayerState: { userDefaults[.storedSoundPlayerState] = .init(episodeID: $0, currentTime: $1) },
            getSoundPlayerSpeedRate: { userDefaults[.soundPlayerSpeedRate] },
            setSoundPlayerSpeedRate: { userDefaults[.soundPlayerSpeedRate] = $0 }
        )
    }
}

extension UserDefaultsClient: DependencyKey {
    public static let liveValue: UserDefaultsClient = .instance(userDefaults: UserDefaults(suiteName: InfoPlist.appGroupID)!)
    public static let testValue: UserDefaultsClient = .init(
        getFeedRefreshedAt: unimplemented(),
        setFeedRefreshedAt: { _ in unimplemented() },
        getStoredSoundPlayerState: unimplemented(),
        setStoredSoundPlayerState: { _, _ in unimplemented() },
        getSoundPlayerSpeedRate: unimplemented(),
        setSoundPlayerSpeedRate: { _ in unimplemented() }
    )
    public static let previewValue: UserDefaultsClient = .instance(userDefaults: .standard)
}

extension DependencyValues {
    public var userDefaultsClient: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}
