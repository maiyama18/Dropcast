import Dependencies

public struct MessageClient: Sendable {
    public var presentError: @Sendable (_ title: String) -> Void

    public init(presentError: @escaping @Sendable (String) -> Void) {
        self.presentError = presentError
    }
}

extension MessageClient: TestDependencyKey {
    public static let testValue: MessageClient = MessageClient(
        presentError: unimplemented()
    )
}

extension DependencyValues {
    public var messageClient: MessageClient {
        get { self[MessageClient.self] }
        set { self[MessageClient.self] = newValue }
    }
}
