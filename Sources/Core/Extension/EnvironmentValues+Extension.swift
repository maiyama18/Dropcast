import SwiftUI

public extension EnvironmentValues {
    var playerBannerHeight: Double {
        get { self[PlayerBannerHeightEnvironmentKey.self] }
        set { self[PlayerBannerHeightEnvironmentKey.self] = newValue }
    }
}

private struct PlayerBannerHeightEnvironmentKey: EnvironmentKey {
    static let defaultValue: Double = 0
}
