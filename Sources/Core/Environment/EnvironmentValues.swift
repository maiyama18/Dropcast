public struct EnvironmentValues: Sendable {
    public var urlScheme: String
}

extension EnvironmentValues {
    public static let forDevelopment: EnvironmentValues = .init(urlScheme: "dropcastdev")
    
    public static let forProduction: EnvironmentValues = .init(urlScheme: "dropcast")
}
