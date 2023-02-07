import Dependencies

public struct MessageClient: Sendable {
    public var presentError: @Sendable (_ title: String) -> Void
    public var presentSuccess: @Sendable (_ title: String) -> Void

    public init(
        presentError: @escaping @Sendable (String) -> Void,
        presentSuccess: @escaping @Sendable (String) -> Void
    ) {
        self.presentError = presentError
        self.presentSuccess = presentSuccess
    }
}

extension MessageClient: TestDependencyKey {
    public static let testValue: MessageClient = MessageClient(
        presentError: unimplemented(),
        presentSuccess: unimplemented()
    )
}

extension DependencyValues {
    public var messageClient: MessageClient {
        get { self[MessageClient.self] }
        set { self[MessageClient.self] = newValue }
    }
}
