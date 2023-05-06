import Dependencies
import Environment
import Foundation

public enum DeepLink {
    public static var showSearch: URL { URL(string: "\(scheme)://show-search")! }
    
    private static var scheme: String {
        @Dependency(\.environmentClient) var environmentClient
        return environmentClient.getValues().urlScheme
    }
}
