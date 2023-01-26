import ComposableArchitecture
import SwiftUI

struct FollowShowsScreen: View {
    let store: StoreOf<FollowShowsReducer>

    @Dependency(\.continuousClock) var clock

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                Group {
                    switch viewStore.showsState {
                    case .prompt:
                        labelView(title: "Search Shows")
                    case .empty:
                        labelView(title: "No Results")
                    case .loaded(let shows):
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(shows) { show in
                                    ShowRowView(show: show)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
                .overlay {
                    if viewStore.searchRequestInFlight {
                        ProgressView()
                            .scaleEffect(2)
                    }
                }
                .navigationTitle("Search shows")
                .navigationBarTitleDisplayMode(.inline)
                .searchable(
                    text: viewStore.binding(get: \.query, send: { .queryChanged(query: $0) }),
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: Text("Show name, Host ...")
                )
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
            }
            .task(id: viewStore.query) {
                do {
                    try await clock.sleep(for: .milliseconds(300))
                    viewStore.send(.queryChangeDebounced)
                } catch {}
            }
        }
    }

    @ViewBuilder
    private func labelView(title: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle.bold())

            Text(title)
                .font(.title2)
        }
        .foregroundStyle(.secondary)
        .frame(maxHeight: .infinity, alignment: .center)
    }

}

struct FollowShowsScreen_Previews: PreviewProvider {
    static var previews: some View {
        FollowShowsScreen(
            store: StoreOf<FollowShowsReducer>(
                initialState: FollowShowsReducer.State(),
                reducer: FollowShowsReducer()
            )
        )
    }
}
