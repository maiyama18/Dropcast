import Components
import ComposableArchitecture
import Entity
import SwiftUI

public struct ShowDetailScreen: View {
    @Environment(\.openURL) var openURL

    let store: StoreOf<ShowDetailReducer>

    public init(store: StoreOf<ShowDetailReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ShowHeaderView(
                        imageURL: viewStore.imageURL,
                        title: viewStore.title,
                        author: viewStore.author,
                        description: viewStore.description,
                        followed: viewStore.followed,
                        requestInFlight: viewStore.taskRequestInFlight,
                        toggleFollowButtonTapped: { viewStore.send(.toggleFollowButtonTapped) }
                    )

                    EpisodeDivider()

                    if viewStore.taskRequestInFlight, viewStore.episodes.isEmpty {
                        ForEach(0..<10) { _ in
                            EpisodeRowView(
                                episode: .fixtureRebuild352,
                                downloadState: .notDownloaded,
                                showsImage: false,
                                onDownloadButtonTapped: {}
                            )
                            .redacted(reason: .placeholder)

                            EpisodeDivider()
                        }
                    } else {
                        ForEach(viewStore.episodes) { episode in
                            EpisodeRowView(
                                episode: episode,
                                downloadState: viewStore.state.downloadState(id: episode.id),
                                showsImage: false,
                                onDownloadButtonTapped: {
                                    viewStore.send(.downloadEpisodeButtonTapped(episode: episode))
                                }
                            )

                            EpisodeDivider()
                        }
                    }
                }
            }
            .padding(.horizontal)
            .task {
                viewStore.send(.task)
            }
            .onDisappear {
                viewStore.send(.disappear)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            viewStore.send(.copyFeedURLButtonTapped)
                        } label: {
                            Label(L10n.copyFeedUrl, systemImage: "doc")
                        }
                        if let linkURL = viewStore.linkURL {
                            Button {
                                openURL(linkURL)
                            } label: {
                                Label(L10n.openInBrowser, systemImage: "globe")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(viewStore.title)
        }
    }
}

struct ShowDetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ShowDetailScreen(
                store: .init(
                    initialState: .init(
                        feedURL: Show.fixtureRebuild.feedURL,
                        imageURL: Show.fixtureRebuild.imageURL,
                        title: Show.fixtureRebuild.title,
                        episodes: Show.fixtureRebuild.episodes
                    ),
                    reducer: ShowDetailReducer()
                )
            )
        }
        .tint(.orange)
    }
}
