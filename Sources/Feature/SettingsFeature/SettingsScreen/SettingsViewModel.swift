import Observation

@MainActor
@Observable
final class SettingsViewModel {
    enum Action {}

    var path: [SettingsRoute] = []

    func handle(action: Action) {}
}
