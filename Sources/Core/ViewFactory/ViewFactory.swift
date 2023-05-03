import Dependencies
import UIKit

public struct ViewFactory: Sendable {
    public var makeSettings: @Sendable @MainActor () -> UIViewController
    
    public init(
        makeSettings: @escaping @Sendable @MainActor () -> UIViewController
    ) {
        self.makeSettings = makeSettings
    }
}

extension ViewFactory: TestDependencyKey {
    public static let testValue: ViewFactory = .init(
        makeSettings: unimplemented()
    )
}

extension DependencyValues {
    public var viewFactory: ViewFactory {
        get { self[ViewFactory.self] }
        set { self[ViewFactory.self] = newValue }
    }
}
