import Foundation

// swiftlint:disable force_cast

public enum InfoPlist {
    public static var appGroupID: String {
        Bundle.main.object(forInfoDictionaryKey: "AppGroupID") as! String
    }
}

// swiftlint:enable force_cast
