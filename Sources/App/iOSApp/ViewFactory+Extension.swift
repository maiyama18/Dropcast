import Dependencies
import FeedFeature
import SettingsFeature
import ShowListFeature
import ViewFactory

extension ViewFactory: DependencyKey {
    public static let liveValue: ViewFactory = .init(
        makeFeed: { FeedViewController() },
        makeShowList: { ShowListViewController() },
        makeSettings: { SettingsViewController() }
    )
}
