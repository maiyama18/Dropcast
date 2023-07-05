import SwiftUI

public struct SettingsScreen: View {
    @StateObject var viewModel: SettingsViewModel = .init()
    
    public init() {}
    
    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            List {
                Section {
                    NavigationLink(value: SettingsRoute.licenses) {
                        Text(L10n.licenses)
                    }
                } header: {
                    Text(L10n.aboutApp)
                }
            }
            .navigationTitle(L10n.settings)
            .navigationDestination(for: SettingsRoute.self) { route in
                switch route {
                case .licenses:
                    LicensesScreen()
                case .licenseDetail(let licenseName, let licenseText):
                    LicenseDetailScreen(licenseName: licenseName, licenseText: licenseText)
                }
            }
        }
    }
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
    }
}
