import ComposableArchitecture
import SwiftUI

struct LicensesScreen: View {
    let store: StoreOf<LicensesReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                ForEach(LicensesPlugin.licenses) { license in
                    Button {
                        viewStore.send(.licenseSelected(license))
                    } label: {
                        Text(license.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .sheet(
                item: viewStore.binding(
                    get: \.selectedLicense,
                    send: { .licenseSelected($0) }
                ),
                onDismiss: { viewStore.send(.licenseSelected(nil)) }
            ) { license in
                NavigationStack {
                    Group {
                        if let licenseText = license.licenseText {
                            ScrollView {
                                Text(licenseText)
                                    .padding()
                            }
                        } else {
                            Text("No License Found")
                        }
                    }
                    .navigationTitle(license.name)
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
            .navigationTitle(L10n.licenses)
        }
    }
}
