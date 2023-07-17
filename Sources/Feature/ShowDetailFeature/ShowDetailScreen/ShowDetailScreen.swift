import Components
import Entity
import NavigationState
import SwiftUI

@MainActor
public struct ShowDetailScreen: View {
    @State var viewModel: ShowDetailViewModel

    @Environment(\.openURL) var openURL

    public init(args: ShowDetailInitArguments) {
        self._viewModel = .init(
            wrappedValue: .init(
                feedURL: args.feedURL,
                imageURL: args.imageURL,
                title: args.title,
                showsEpisodeActionButtons: args.showsEpisodeActionButtons,
                episodes: args.episodes,
                author: args.author,
                description: args.description,
                linkURL: args.linkURL,
                followed: args.followed
            )
        )
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ShowHeaderView(
                    imageURL: viewModel.imageURL,
                    title: viewModel.title,
                    author: viewModel.author,
                    description: viewModel.description,
                    followed: viewModel.followed,
                    isFetchingShow: viewModel.isFetchingShow,
                    toggleFollowButtonTapped: { viewModel.handle(action: .tapToggleFollowButton) }
                )

                EpisodeDivider()

                if viewModel.episodes.isEmpty {
                    ForEach(0..<10) { _ in
                        EpisodeRowView(
                            episode: .fixtureRebuild352,
                            downloadState: .notDownloaded,
                            showsPlayButton: viewModel.showsEpisodeActionButtons,
                            showsImage: false,
                            onDownloadButtonTapped: {}
                        )
                        .redacted(reason: .placeholder)

                        EpisodeDivider()
                    }
                } else {
                    ForEach(viewModel.episodes) { episode in
                        EpisodeRowView(
                            episode: episode,
                            downloadState: viewModel.downloadState(id: episode.id),
                            showsPlayButton: viewModel.showsEpisodeActionButtons,
                            showsImage: false,
                            onDownloadButtonTapped: {
                                viewModel.handle(action: .tapDownloadEpisodeButton(episode: episode))
                            }
                        )

                        EpisodeDivider()
                    }
                }
            }
        }
        .padding(.horizontal)
        .onAppear { viewModel.handle(action: .appear) }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        viewModel.handle(action: .tapCopyFeedURLButton)
                    } label: {
                        Label(
                            title: { Text("Copy Feed URL", bundle: .module) },
                            icon: { Image(systemName: "doc") }
                        )
                    }
                    if let linkURL = viewModel.linkURL {
                        Button {
                            openURL(linkURL)
                        } label: {
                            Label(
                                title: { Text("Open in Browser", bundle: .module) },
                                icon: { Image(systemName: "globe") }
                            )
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.title)
    }
}
