import Entity
import Formatter
import NukeUI
import SwiftUI

public struct EpisodeRowView: View {
    var episode: Episode
    var downloadState: EpisodeDownloadState
    var showsImage: Bool
    var onDownloadButtonTapped: () -> Void

    public init(
        episode: Episode,
        downloadState: EpisodeDownloadState,
        showsImage: Bool,
        onDownloadButtonTapped: @escaping () -> Void
    ) {
        self.episode = episode
        self.downloadState = downloadState
        self.showsImage = showsImage
        self.onDownloadButtonTapped = onDownloadButtonTapped
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if showsImage {
                LazyImage(url: episode.showImageURL) { state in
                    if let image = state.image {
                        image
                    } else {
                        Color.secondary
                            .opacity(0.3)
                    }
                }
                .frame(width: 64, height: 64)
                .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 0) {
                    Text(episode.publishedAt.formatted(date: .numeric, time: .omitted))
                    Text("・")
                    Text(formatEpisodeDuration(duration: episode.duration))
                }
                .font(.footnote.monospacedDigit())

                Text(episode.title)
                    .font(.body.bold())
                    .lineLimit(2)

                if let subtitle = episode.subtitle {
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }

                HStack(spacing: 12) {
                    Button {
                        onDownloadButtonTapped()
                    } label: {
                        switch downloadState {
                        case .notDownloaded:
                            Image(systemName: "arrow.down.to.line.circle")
                        case .pushedToDownloadQueue:
                            Image(systemName: "arrow.clockwise.circle")
                                .tint(.gray.opacity(0.5))
                        case .downloading(let progress):
                            ProgressSystemImage(
                                systemName: "stop.circle",
                                progress: progress,
                                onColor: .orange,
                                offColor: .gray.opacity(0.5)
                            )
                        case .downloaded:
                            Image(systemName: "play.circle")
                        }
                    }
                    .font(.title)
                    
                    Spacer()
                    
                    Button {
                        print("misc")
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.title)
                    }

                    Button {
                        print("misc")
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title)
                    }
                }
            }
        }
    }
}

struct EpisodeRowView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                EpisodeRowView(
                    episode: .fixtureRebuild352,
                    downloadState: .notDownloaded,
                    showsImage: true,
                    onDownloadButtonTapped: {}
                )
                
                EpisodeRowView(
                    episode: .fixtureRebuild351,
                    downloadState: .pushedToDownloadQueue,
                    showsImage: true,
                    onDownloadButtonTapped: {}
                )
                
                EpisodeRowView(
                    episode: .fixtureRebuild351,
                    downloadState: .downloading(progress: 0.4),
                    showsImage: true,
                    onDownloadButtonTapped: {}
                )
                
                EpisodeRowView(
                    episode: .fixtureRebuild350,
                    downloadState: .downloaded,
                    showsImage: true,
                    onDownloadButtonTapped: {}
                )
            }
            .padding(.horizontal)
            .tint(.orange)
        }
    }
}
