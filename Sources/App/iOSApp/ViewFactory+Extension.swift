import Dependencies
import FeedFeature
import SettingsFeature
import ViewFactory

extension ViewFactory: DependencyKey {
    public static let liveValue: ViewFactory = .init(
        makeFeed: { FeedViewController() },
        makeSettings: { SettingsViewController() }
    )
}
