import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    enum Action {}
    
    @Published var path: [SettingsRoute] = []

    func handle(action: Action) {}
}
