import Dependencies
import SwiftUI

public struct ScreenProvider: Sendable {

    public var provideShowDetailScreen: @Sendable (_ args: ShowDetailScreenArgs) -> AnyView

    public init(provideShowDetailScreen: @escaping @Sendable (_ args: ShowDetailScreenArgs) -> AnyView) {
        self.provideShowDetailScreen = provideShowDetailScreen
    }
}

extension ScreenProvider: TestDependencyKey {
    public static let testValue: ScreenProvider = ScreenProvider(
        provideShowDetailScreen: unimplemented()
    )
    public static var previewValue: ScreenProvider = ScreenProvider(
        provideShowDetailScreen: { _ in AnyView(Text("ShowDetail")) }
    )
}

extension DependencyValues {
    public var screenProvider: ScreenProvider {
        get { self[ScreenProvider.self] }
        set { self[ScreenProvider.self] = newValue }
    }
}
