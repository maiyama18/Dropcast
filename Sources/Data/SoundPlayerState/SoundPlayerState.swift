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
        case pausing(episode: Episode)
    }
    
    public static let shared = SoundPlayerState()
    
    public var state: State = .notPlaying
    
    private var audioPlayer: AVAudioPlayer? = nil
    private let context: NSManagedObjectContext = CloudKitPersistentProvider.shared.viewContext
    
    public func startPlaying(url: URL, episode: Episode) throws {
        // 別のファイルが再生中であれば pause する
        if case .playing(_, let episode) = state {
            pause(episode: episode)
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
                return
            }
            try playingState.startPlaying(atTime: audioPlayer.currentTime)
        }
        context.saveWithErrorHandling { _ in assertionFailure() }
    }
    
    public func pause(episode: Episode) {
        audioPlayer?.stop()
        
        self.state = .pausing(episode: episode)
        
        guard let playingState = findOrCreatePlayingState(episodeID: episode.id) else {
            assertionFailure()
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
