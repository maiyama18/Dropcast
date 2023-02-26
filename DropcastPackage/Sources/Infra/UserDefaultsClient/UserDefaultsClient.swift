import Build
import Defaults
import Dependencies
import Foundation

// > The UserDefaults class is thread-safe.
// ref: https://developer.apple.com/documentation/foundation/userdefaults
extension UserDefaults: @unchecked Sendable {}

extension Defaults.Keys {
    static let feedRefreshedAt = Key<Date?>("feedRefreshedAt")
}

public struct UserDefaultsClient: Sendable {
    public var getFeedRefreshedAt: @Sendable () -> Date?
    public var setFeedRefreshedAt: @Sendable (Date) -> Void
}

extension UserDefaultsClient {
    public static func instance(userDefaults: UserDefaults) -> UserDefaultsClient {
        .init(
            getFeedRefreshedAt: { userDefaults[.feedRefreshedAt] },
            setFeedRefreshedAt: { userDefaults[.feedRefreshedAt] = $0 }
        )
    }
}

extension UserDefaultsClient: DependencyKey {
    public static let liveValue: UserDefaultsClient = .instance(userDefaults: UserDefaults(suiteName: InfoPlist.appGroupID)!)
    public static let testValue: UserDefaultsClient = .init(
        getFeedRefreshedAt: unimplemented(),
        setFeedRefreshedAt: unimplemented()
    )
}

extension DependencyValues {
    public var userDefaultsClient: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}
