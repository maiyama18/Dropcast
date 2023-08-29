import SwiftUI

public struct PlayerBannerHeightKey: PreferenceKey {
    public static let defaultValue: Double = 0
    
    public static func reduce(value: inout Double, nextValue: () -> Double) {
        value = max(value, nextValue())
    }
}
