import AsyncAlgorithms
import Dependencies

/// A component to instruct screens to do some transitions for handling deep links.
public struct ScreenTransitionCoordinator: Sendable {
    public var changeTabToShows: AsyncChannel<Void> = .init()
    public var openShowSearch: AsyncChannel<Void> = .init()
}

extension ScreenTransitionCoordinator: DependencyKey {
    public static let liveValue: ScreenTransitionCoordinator = .init()
}

extension DependencyValues {
    public var screenTransitionCoordinator: ScreenTransitionCoordinator {
        get { self[ScreenTransitionCoordinator.self] }
        set { self[ScreenTransitionCoordinator.self] = newValue }
    }
}
