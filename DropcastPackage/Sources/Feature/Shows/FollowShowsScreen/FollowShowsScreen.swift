import ComposableArchitecture
import SwiftUI

struct FollowShowsScreen: View {
    let store: StoreOf<FollowShowsReducer>

    @Dependency(\.continuousClock) var clock

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack(path: viewStore.binding(get: \.path, send: { .pathChanged(path: $0) })) {
                Group {
                    switch viewStore.showsState {
                    case .prompt:
                        labelView(title: "Search Shows")
                    case .empty:
                        labelView(title: "No Results")
                    case .loaded(let shows):
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(shows) { show in
                                    ShowRowView(show: show)
                                        .padding(.horizontal)
                                        .containerShape(Rectangle())
                                        .onTapGesture {
                                            viewStore.send(.showTapped(show: show))
                                        }
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
                .navigationTitle("Follow shows")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: FollowShowsReducer.State.Route.self) { route in
                    switch route {
                    case .showDetail(let show):
                        Text(show.title)
                    }
                }
                .searchable(
                    text: viewStore.binding(get: \.query, send: { .queryChanged(query: $0) }),
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: Text("Show name, Host, Feed URL ...")
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
        NavigationStack {
            FollowShowsScreen(
                store: StoreOf<FollowShowsReducer>(
                    initialState: FollowShowsReducer.State(),
                    reducer: FollowShowsReducer()
                )
            )
        }
        .tint(.orange)
    }
}
