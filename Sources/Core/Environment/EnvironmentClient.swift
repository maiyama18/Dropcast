import Dependencies

public struct EnvironmentClient: Sendable {
    public var getValues: @Sendable () -> EnvironmentValues
}

extension EnvironmentClient {
    static let live: EnvironmentClient = .init(
        getValues: {
            switch currentEnvironment.value {
            case .develop:
                return .forDevelopment
            case .production:
                return .forProduction
            }
        }
    )
}

extension EnvironmentClient: DependencyKey {
    public static let liveValue: EnvironmentClient = .live
}

extension DependencyValues {
    public var environmentClient: EnvironmentClient {
        get { self[EnvironmentClient.self] }
        set { self[EnvironmentClient.self] = newValue }
    }
}
