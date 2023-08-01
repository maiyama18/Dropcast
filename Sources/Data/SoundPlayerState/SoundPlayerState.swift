import AVFoundation
import CoreData
import DatabaseClient
import Dependencies
import Entity
import Foundation
import Observation

@Observable
@MainActor
public final class SoundPlayerState: NSObject {
    public enum State {
        case notPlaying
        case playing(url: URL, episode: Episode)
        case pausing(url: URL, episode: Episode)
    }
    
    public static let shared = SoundPlayerState()
    
    public var state: State = .notPlaying
    
    private var audioPlayer: AVAudioPlayer? = nil
    private let context: NSManagedObjectContext = CloudKitPersistentProvider.shared.viewContext
    
    public func startPlayingCurrent() throws {
        guard case .pausing(let url, let episode) = state else {
            return
        }
        try startPlaying(url: url, episode: episode)
    }
    
    public func pauseCurrent() {
        guard case .playing(let url, let episode) = state else {
            return
        }
        pause(url: url, episode: episode)
    }
    
    public func startPlaying(url: URL, episode: Episode) throws {
        // 別のファイルが再生中であれば pause する
        if case .playing(let url, let episode) = state {
            pause(url: url, episode: episode)
        }
            
        let playingState = try? context.fetch(EpisodePlayingStateRecord.withEpisodeID(episode.id)).first
        
        let audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer.delegate = self
        audioPlayer.currentTime = playingState?.lastPausedTime ?? 0
        audioPlayer.play()
        self.audioPlayer = audioPlayer
        
        self.state = .playing(url: url, episode: episode)
        
        if let playingState {
            try playingState.startPlaying(atTime: audioPlayer.currentTime)
        } else {
            guard let playingState = findOrCreatePlayingState(episodeID: episode.id) else {
                assertionFailure()
                state = .notPlaying
                return
            }
            try playingState.startPlaying(atTime: audioPlayer.currentTime)
        }
        context.saveWithErrorHandling { _ in assertionFailure() }
    }
    
    public func pause(url: URL, episode: Episode) {
        audioPlayer?.stop()
        
        self.state = .pausing(url: url, episode: episode)
        
        guard let playingState = findOrCreatePlayingState(episodeID: episode.id) else {
            assertionFailure()
            state = .notPlaying
            return
        }
        playingState.pause(atTime: audioPlayer?.currentTime ?? 0)
        context.saveWithErrorHandling { _ in assertionFailure() }
        
        self.audioPlayer = nil
    }
    
    private func findOrCreatePlayingState(episodeID: Episode.ID) -> EpisodePlayingStateRecord? {
        if let playingState = try? context.fetch(EpisodePlayingStateRecord.withEpisodeID(episodeID)).first {
            return playingState
        }
        if let episode = try? context.fetch(EpisodeRecord.withID(episodeID)).first {
            let playingState = EpisodePlayingStateRecord(context: context)
            playingState.episode = episode
            return playingState
        }
        return nil
    }
}

extension SoundPlayerState: AVAudioPlayerDelegate {
    nonisolated public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
    }
    
    nonisolated public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }
}
