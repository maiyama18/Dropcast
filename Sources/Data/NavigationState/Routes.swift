import Database

public enum PodcastRoute: Hashable {
    case showDetail(args: ShowDetailInitArguments)
    case episodeDetail(episode: EpisodeRecord)
}

public enum SettingsRoute: Hashable {
    case licenses
    case licenseDetail(licenseName: String, licenseText: String)
}
