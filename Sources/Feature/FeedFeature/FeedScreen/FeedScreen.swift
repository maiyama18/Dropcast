import Components
import DatabaseClient
import Entity
import SwiftUI

public struct FeedScreen: View {
    @ObservedObject var viewModel: FeedViewModel

    public var body: some View {
        Group {
            if let episodes = viewModel.episodes {
                if episodes.isEmpty {
                    emptyView(onButtonTapped: {
                        print("TODO")
                    })
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
        .navigationTitle(L10n.feed)
        .task {
            await viewModel.handle(action: .appear)
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

            Text(L10n.noFeed)
                .font(.title3.bold())
                .foregroundStyle(.secondary)

            Spacer()
                .frame(height: 16)

            Button(L10n.followShows) {
                onButtonTapped()
            }
            .tint(.orange)
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }
}
