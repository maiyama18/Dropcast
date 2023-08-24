public enum PodcastRoute: Hashable {
    case showDetail(args: ShowDetailInitArguments)
}

public enum SettingsRoute: Hashable {
    case licenses
    case licenseDetail(licenseName: String, licenseText: String)
}
