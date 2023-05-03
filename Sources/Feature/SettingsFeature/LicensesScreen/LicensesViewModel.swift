import Combine
import Extension

final class LicensesViewModel: ObservableObject {
    enum Action {
        case tapLicense(license: LicensesPlugin.License)
    }
    
    enum Event {
        case pushLicenseDetail(licenseName: String, licenseText: String)
    }
    
    private(set) var licenses: [LicensesPlugin.License] = LicensesPlugin.licenses
    
    var eventStream: AsyncStream<Event> { eventSubject.eraseToStream() }
    private let eventSubject: PassthroughSubject<Event, Never> = .init()
    
    func handle(action: Action) {
        switch action {
        case .tapLicense(let license):
            guard let licenseText = license.licenseText else { return }
            eventSubject.send(.pushLicenseDetail(licenseName: license.name, licenseText: licenseText))
        }
    }
}
