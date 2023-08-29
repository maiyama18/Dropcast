import Database
import Dependencies
import Entity
import MessageClient
import SoundFileState
import SoundPlayerState
import SwiftUI

@MainActor
public struct EpisodeActionButton: View {
    enum SoundState {
        case notPlaying
        case playing
        case pausing
    }
    
    private let episode: EpisodeRecord
    
    @Environment(SoundFileState.self) private var soundFileState
    @Environment(SoundPlayerState.self) private var soundPlayerState
    
    @Dependency(\.messageClient) private var messageClient
    
    public init(episode: EpisodeRecord) {
        self.episode = episode
    }
    
    public var body: some View {
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
