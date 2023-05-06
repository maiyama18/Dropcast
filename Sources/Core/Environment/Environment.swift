import Dependencies

public enum Environment: Sendable {
    case develop
    case production
}

internal let currentEnvironment: LockIsolated<Environment> = .init(.production)

public func setEnvironment(_ environment: Environment) {
    currentEnvironment.withValue { $0 = environment }
}
