import ComposableArchitecture
import ShowDetailFeature
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
                                    showRowLink(viewStore: viewStore, show: SimpleShow(show: show))
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
                .navigationTitle(L10n.shows)
            }
            .task {
                viewStore.send(.task)
            }
            .sheet(
                isPresented: viewStore.binding(
                    get: \.showSearchPresented,
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
    private func showRowLink(viewStore: ViewStoreOf<ShowListReducer>, show: SimpleShow) -> some View {
        NavigationLink(
            destination: IfLetStore(
                self.store.scope(
                    state: \.selectedShowState?.value,
                    action: { .showDetail($0) }
                )
            ) {
                ShowDetailScreen(store: $0, showsEpisodePlayButtons: true)
            },
            tag: show.feedURL,
            selection: viewStore.binding(
                get: \.selectedShowState?.id,
                send: { .showDetailSelected(feedURL: $0) }
            )
        ) {
            ShowRowView(show: show)
                .swipeActions(allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        viewStore.send(.showSwipeToDeleted(feedURL: show.feedURL))
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                }
        }
        .tint(.primary)
    }

    @ViewBuilder
    private func emptyView(onButtonTapped: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            Image(systemName: "face.dashed")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Spacer()
                .frame(height: 8)

            Text(L10n.noShows)
                .font(.title3.bold())
                .foregroundStyle(.secondary)

            Spacer()
                .frame(height: 16)

            Button(L10n.followFavoriteShows) {
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
                    _ = $0.databaseClient.followShow(.fixtureRebuild)
                    _ = $0.databaseClient.followShow(.fixtureSwiftBySundell)
                }) {
                    ShowListReducer()
                }
            )
        )
        .tint(.orange)
    }
}
