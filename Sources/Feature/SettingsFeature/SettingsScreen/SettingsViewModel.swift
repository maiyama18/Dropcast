import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    enum Action {
        case tapLicenses
    }
    
    enum Event {
        case pushLicenses
    }
    
    var eventStream: AsyncStream<Event> { eventSubject.eraseToStream() }
    private let eventSubject: PassthroughSubject<Event, Never> = .init()
    
    func handle(action: Action) {
        switch action {
        case .tapLicenses:
            eventSubject.send(.pushLicenses)
        }
    }
}
