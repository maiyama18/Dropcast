import SwiftUI

public struct SettingsScreen: View {
    @ObservedObject var viewModel: SettingsViewModel

    public var body: some View {
        List {
            Section {
                Button(L10n.licenses) {
                    viewModel.handle(action: .tapLicenses)
                }
            } header: {
                Text(L10n.aboutApp)
            }
        }
        .navigationTitle(L10n.settings)
    }
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen(viewModel: .init())
    }
}
