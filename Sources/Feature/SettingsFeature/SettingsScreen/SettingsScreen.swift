import ComposableArchitecture
import SwiftUI

public struct SettingsScreen: View {
    let store: StoreOf<SettingsReducer>

    public init(store: StoreOf<SettingsReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                List {
                    Section {
                        NavigationLink(
                            tag: SettingsReducer.Destination.Tag.licenses,
                            selection: viewStore.binding(
                                get: \.destination?.tag,
                                send: { .destinationSet(tag: $0) }
                            ),
                            destination: {
                                IfLetStore(
                                    store.scope(
                                        state: { parent in
                                            switch parent.destination {
                                            case .licenses(let licensesState):
                                                return licensesState
                                            default:
                                                return nil
                                            }
                                        },
                                        action: { .destination(.licenses($0)) }
                                    ),
                                    then: LicensesScreen.init(store:)
                                )
                            }) {
                            Text(L10n.licenses)
                        }
                    } header: {
                        Text(L10n.aboutApp)
                    }
                }
                .navigationTitle(L10n.settings)
            }
        }
    }
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen(
            store: .init(
                initialState: .init(),
                reducer: SettingsReducer()
            )
        )
    }
}
