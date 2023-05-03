import Dependencies
import ViewFactory
import SettingsFeature

extension ViewFactory: DependencyKey {
    public static let liveValue: ViewFactory = .init(
        makeSettings: { SettingsViewController() }
    )
}
