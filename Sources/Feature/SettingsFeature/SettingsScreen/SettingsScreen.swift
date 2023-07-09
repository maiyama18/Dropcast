import SwiftUI

@MainActor
public struct SettingsScreen: View {
    @State var viewModel: SettingsViewModel = .init()

    public init() {}

    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            List {
                Section {
                    NavigationLink(value: SettingsRoute.licenses) {
                        Text("Licenses", bundle: .module)
                    }
                } header: {
                    Text("About App", bundle: .module)
                }
            }
            .navigationTitle(Text("Settings", bundle: .module))
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

//#if DEBUG
//
//#Preview {
//    SettingsScreen()
//}
//
//#endif
