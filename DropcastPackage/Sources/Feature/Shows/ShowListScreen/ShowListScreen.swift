import ComposableArchitecture
import SwiftUI

public struct ShowListScreen: View {
    let store: StoreOf<ShowListReducer>

    public init(store: StoreOf<ShowListReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                Group {
                    if let shows = viewStore.shows {
                        if shows.isEmpty {
                            emptyView(onButtonTapped: { viewStore.send(.openShowSearchButtonTapped) })
                        } else {
                            List {
                                ForEach(shows) { show in
                                    ShowRowView(show: show)
                                }
                            }
                            .listStyle(.plain)
                        }
                    } else {
                        ProgressView()
                            .scaleEffect(2)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewStore.send(.openShowSearchButtonTapped)
                        } label: {
                            Image(systemName: "plus")
                                .bold()
                        }
                    }
                }
                .navigationTitle("Shows")
            }
            .task {
                viewStore.send(.task)
            }
            .sheet(
                isPresented: viewStore.binding(
                    get: \.followShowsPresented,
                    send: { _ in .showSearchDismissed }
                )
            ) {
                IfLetStore(store.scope(state: \.showSearchState, action: { .showSearch($0) })) {
                    ShowSearchScreen(store: $0)
                }
            }
        }
    }

    @ViewBuilder
    private func emptyView(onButtonTapped: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            Image(systemName: "face.dashed")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Spacer()
                .frame(height: 8)

            Text("No shows")
                .font(.title2)
                .foregroundStyle(.secondary)

            Spacer()
                .frame(height: 16)

            Button("Follow your favorite show!") {
                onButtonTapped()
            }
            .tint(.orange)
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }
}

struct ShowListScreen_Previews: PreviewProvider {
    static var previews: some View {
        ShowListScreen(
            store: StoreOf<ShowListReducer>(
                initialState: ShowListReducer.State(),
                reducer: withDependencies({
                    try? $0.databaseClient.followShow(.fixtureRebuild)
                    try? $0.databaseClient.followShow(.fixtureSwiftBySundell)
                }) {
                    ShowListReducer()
                }
            )
        )
        .tint(.orange)
    }
}
