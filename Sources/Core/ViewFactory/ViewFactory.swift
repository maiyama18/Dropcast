import Dependencies
import UIKit

public struct ViewFactory: Sendable {
    public var makeFeed: @Sendable @MainActor () -> UIViewController
    public var makeShowList: @Sendable @MainActor () -> UIViewController
    public var makeShowDetail: @Sendable @MainActor (ShowDetailInitArguments) -> UIViewController
    public var makeSettings: @Sendable @MainActor () -> UIViewController

    public init(
        makeFeed: @escaping @Sendable @MainActor () -> UIViewController,
        makeShowList: @escaping @Sendable @MainActor () -> UIViewController,
        makeShowDetail: @escaping @Sendable @MainActor (ShowDetailInitArguments) -> UIViewController,
        makeSettings: @escaping @Sendable @MainActor () -> UIViewController
    ) {
        self.makeFeed = makeFeed
        self.makeShowList = makeShowList
        self.makeShowDetail = makeShowDetail
        self.makeSettings = makeSettings
    }
}

extension ViewFactory: TestDependencyKey {
    public static let testValue: ViewFactory = .init(
        makeFeed: unimplemented(),
        makeShowList: unimplemented(),
        makeShowDetail: { _ in unimplemented() },
        makeSettings: unimplemented()
    )
}

extension DependencyValues {
    public var viewFactory: ViewFactory {
        get { self[ViewFactory.self] }
        set { self[ViewFactory.self] = newValue }
    }
}
