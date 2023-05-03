import SwiftUI

struct LicensesScreen: View {
    @ObservedObject var viewModel: LicensesViewModel

    var body: some View {
        List {
            ForEach(viewModel.licenses) { license in
                if license.licenseText != nil {
                    Button(license.name) {
                        viewModel.handle(action: .tapLicense(license: license))
                    }
                } else {
                    Text(license.name)
                }
            }
        }
        .navigationTitle(L10n.licenses)
    }
}
