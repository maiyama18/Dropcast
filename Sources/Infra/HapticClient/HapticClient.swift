import Dependencies
import UIKit

@MainActor let generator = UIImpactFeedbackGenerator(style: .medium)

public struct HapticClient: Sendable {
    public var medium: @MainActor @Sendable () -> Void
}

extension HapticClient {
    public static let live: HapticClient = HapticClient(
        medium: {
            generator.prepare()
            generator.impactOccurred()
        }
    )
}

extension HapticClient: DependencyKey {
    public static let liveValue: HapticClient = .live
    public static let testValue: HapticClient = HapticClient(
        medium: unimplemented()
    )
}

extension DependencyValues {
    public var hapticClient: HapticClient {
        get { self[HapticClient.self] }
        set { self[HapticClient.self] = newValue }
    }
}
