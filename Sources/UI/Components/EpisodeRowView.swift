import Dependencies
import Entity
import Formatter
import MessageClient
import NukeUI
import SoundFileState
import SwiftUI

public struct EpisodeRowView: View {
    var episode: Episode
    var showsPlayButton: Bool
    var showsImage: Bool

    @Environment(SoundFileState.self) private var soundFileState
    @Dependency(\.messageClient) private var messageClient
        
    public init(
        episode: Episode,
        showsPlayButton: Bool,
        showsImage: Bool
    ) {
        self.episode = episode
        self.showsPlayButton = showsPlayButton
        self.showsImage = showsImage
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
                        switch downloadState {
                        case .notDownloaded:
                            do {
                                try soundFileState.startDownload(episode: episode)
                            } catch {
                                messageClient.presentError(String(localized: "Failed to download episode \(episode.title)", bundle: .module))
                            }
                        case .pushedToDownloadQueue:
                            break
                        case .downloading:
                            soundFileState.cancelDownload(episode: episode)
                        case .downloaded:
                            // TODO: play sound
                            break
                        }
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
                    .opacity(showsPlayButton ? 1 : 0)
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
    
    private var downloadState: EpisodeDownloadState {
        soundFileState.downloadStates[episode.id] ?? .notDownloaded
    }
}

#if DEBUG

#Preview {
    ScrollView {
        LazyVStack(spacing: 8) {
            EpisodeRowView(
                episode: .fixtureRebuild352,
                showsPlayButton: true,
                showsImage: true
            )

            EpisodeRowView(
                episode: .fixtureRebuild351,
                showsPlayButton: true,
                showsImage: true
            )

            EpisodeRowView(
                episode: .fixtureRebuild351,
                showsPlayButton: true,
                showsImage: true
            )

            EpisodeRowView(
                episode: .fixtureRebuild350,
                showsPlayButton: true,
                showsImage: true
            )
        }
        .padding(.horizontal)
        .tint(.orange)
    }
}

#endif
