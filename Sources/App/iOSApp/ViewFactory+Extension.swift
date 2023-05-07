import Dependencies
import FeedFeature
import SettingsFeature
import ShowDetailFeature
import ShowListFeature
import ViewFactory

extension ViewFactory: DependencyKey {
    public static let liveValue: ViewFactory = .init(
        makeFeed: { FeedViewController() },
        makeShowList: { ShowListViewController() },
        makeShowDetail: { arguments in
            ShowDetailViewController(
                showsEpisodeActionButtons: arguments.showsEpisodeActionButtons,
                feedURL: arguments.feedURL,
                imageURL: arguments.imageURL,
                title: arguments.title,
                episodes: arguments.episodes,
                author: arguments.author,
                description: arguments.description,
                linkURL: arguments.linkURL,
                followed: arguments.followed
            )
        },
        makeSettings: { SettingsViewController() }
    )
}
