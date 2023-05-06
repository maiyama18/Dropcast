import Components
import Entity
import SwiftUI

public struct ShowDetailScreen: View {
    @ObservedObject var viewModel: ShowDetailViewModel

    /// この画面においてエピソードのダウンロードや再生が可能かどうかを表す。
    /// 検索画面から遷移した場合は false になる。
    let showsEpisodeActionButtons: Bool

    @Environment(\.openURL) var openURL

    init(
        viewModel: ShowDetailViewModel,
        showsEpisodeActionButtons: Bool
    ) {
        self.viewModel = viewModel
        self.showsEpisodeActionButtons = showsEpisodeActionButtons
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
                            showsPlayButton: showsEpisodeActionButtons,
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
                            showsPlayButton: showsEpisodeActionButtons,
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
                        Label(L10n.copyFeedUrl, systemImage: "doc")
                    }
                    if let linkURL = viewModel.linkURL {
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
        .navigationTitle(viewModel.title)
    }
}
