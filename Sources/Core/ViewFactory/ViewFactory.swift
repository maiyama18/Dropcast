import Dependencies
import UIKit

public struct ViewFactory: Sendable {
    public var makeFeed: @Sendable @MainActor () -> UIViewController
    public var makeSettings: @Sendable @MainActor () -> UIViewController
    
    public init(
        makeFeed: @escaping @Sendable @MainActor () -> UIViewController,
        makeSettings: @escaping @Sendable @MainActor () -> UIViewController
    ) {
        self.makeFeed = makeFeed
        self.makeSettings = makeSettings
    }
}

extension ViewFactory: TestDependencyKey {
    public static let testValue: ViewFactory = .init(
        makeFeed: unimplemented(),
        makeSettings: unimplemented()
    )
}

extension DependencyValues {
    public var viewFactory: ViewFactory {
        get { self[ViewFactory.self] }
        set { self[ViewFactory.self] = newValue }
    }
}
