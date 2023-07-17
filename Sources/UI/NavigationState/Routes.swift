public enum ShowListRoute: Hashable {
    case showDetail(args: ShowDetailInitArguments)
}

public enum ShowSearchRoute: Hashable {
    case showDetail(args: ShowDetailInitArguments)
}

public enum SettingsRoute: Hashable {
    case licenses
    case licenseDetail(licenseName: String, licenseText: String)
}
