import Components
import DatabaseClient
import Entity
import SwiftUI

public struct FeedScreen: View {
    @StateObject var viewModel: FeedViewModel = .init()

    public init() {}

    public var body: some View {
        Group {
            if let episodes = viewModel.episodes {
                if episodes.isEmpty {
                    ContentUnavailableView(
                        label: {
                            Label(
                                title: { Text("No episodes in feed", bundle: .module) },
                                icon: { Image(systemName: "list.dash") }
                            )
                        },
                        actions: {
                            Button(action: { Task { await viewModel.handle(action: .tapAddShowButton) } }) {
                                Text("Follow your favorite shows!", bundle: .module)
                            }
                        }
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(episodes) { episode in
                                EpisodeRowView(
                                    episode: episode,
                                    downloadState: viewModel.downloadState(id: episode.id),
                                    showsPlayButton: true,
                                    showsImage: true,
                                    onDownloadButtonTapped: {
                                        Task {
                                            await viewModel.handle(action: .tapDownloadEpisodeButton(episode: episode))
                                        }
                                    }
                                )

                                EpisodeDivider()
                            }
                        }
                        .padding(.horizontal)
                    }
                    .refreshable {
                        await viewModel.handle(action: .pullToRefresh)
                    }
                }
            } else {
                ProgressView()
                    .scaleEffect(2)
            }
        }
        .navigationTitle(Text("Feed", bundle: .module))
        .task {
            await viewModel.handle(action: .appear)
        }
    }
}
