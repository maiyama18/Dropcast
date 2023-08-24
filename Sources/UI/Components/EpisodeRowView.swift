import Database
import Dependencies
import Entity
import Formatter
import MessageClient
import NukeUI
import SoundFileState
import SoundPlayerState
import SwiftUI

@MainActor
public struct EpisodeRowView: View {
    enum SoundState {
        case notPlaying
        case playing
        case pausing
    }
    
    var episode: EpisodeRecord
    var showsPlayButton: Bool
    var showsImage: Bool
    
    @Environment(SoundFileState.self) private var soundFileState
    @Environment(SoundPlayerState.self) private var soundPlayerState
    @Environment(\.redactionReasons) private var redactionReasons
    @Dependency(\.messageClient) private var messageClient
    
    public init(
        episode: EpisodeRecord,
        showsPlayButton: Bool,
        showsImage: Bool
    ) {
        self.episode = episode
        self.showsPlayButton = showsPlayButton
        self.showsImage = showsImage
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if showsImage, let showImageURL = episode.show?.imageURL {
                LazyImage(url: showImageURL) { state in
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
                
                Group {
                    if episode.playingState?.isCompleted == true {
                        Text(Image(systemName: "checkmark.circle.fill"))
                            + Text(" ")
                            + Text(episode.title)
                    } else {
                        Text(episode.title)
                    }
                }
                .font(.body.bold())
                .lineLimit(2)
                
                if let subtitle = episode.subtitle {
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
                
                HStack(spacing: 12) {
                    actionButton
                        .tint(.accentColor)
                    
                    Spacer()
                    
                    Button {
                        print("misc")
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    
                    Button {
                        print("misc")
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                .font(.title)
                .tint(.accentColor)
            }
        }
        .multilineTextAlignment(.leading)
        .tint(.primary)
    }
    
    private var actionButton: some View {
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
                switch soundState {
                case .notPlaying, .pausing:
                    do {
                        try soundPlayerState.startPlaying(episode: episode)
                    } catch {
                        messageClient.presentError(String(localized: "Failed to play episode \(episode.title)", bundle: .module))
                    }
                case .playing:
                    soundPlayerState.pause(episode: episode)
                }
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
                switch soundState {
                case .notPlaying, .pausing:
                    Image(systemName: "play.circle")
                case .playing:
                    Image(systemName: "pause.circle")
                }
            }
        }
        .opacity(showsPlayButton ? 1 : 0)
    }
    
    private var downloadState: EpisodeDownloadState {
        soundFileState.downloadStates[episode.id] ?? .notDownloaded
    }
    
    private var soundState: SoundState {
        switch soundPlayerState.state {
        case .notPlaying:
            return .notPlaying
        case .playing(let playingEpisode):
            return episode.id == playingEpisode.id ? .playing : .notPlaying
        case .pausing(let playingEpisode):
            return episode.id == playingEpisode.id ? .pausing : .notPlaying
        }
    }
}
