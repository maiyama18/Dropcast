import AVFoundation
import CoreData
import Database
import Dependencies
import Entity
import Foundation
import Observation

@Observable
@MainActor
public final class SoundPlayerState: NSObject {
    public enum State {
        case notPlaying
        case playing(url: URL, episode: EpisodeRecord)
        case pausing(url: URL, episode: EpisodeRecord)
    }
    
    public static let shared = SoundPlayerState()
    
    public var state: State = .notPlaying
    
    private var audioPlayer: AVAudioPlayer? = nil
    private let context: NSManagedObjectContext = CloudKitPersistentProvider.shared.viewContext
    
    public func startPlaying(url: URL, episode: EpisodeRecord) throws {
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
    }
    
    public func pause(url: URL, episode: EpisodeRecord) {
        audioPlayer?.stop()
        
        self.state = .pausing(url: url, episode: episode)
        
        guard let playingState = findOrCreatePlayingState(episodeID: episode.id) else {
            assertionFailure()
            state = .notPlaying
            return
        }
        try? playingState.pause(atTime: audioPlayer?.currentTime ?? 0)
        
        self.audioPlayer = nil
    }
    
    private func move(to time: TimeInterval, audioPlayer: AVAudioPlayer) {
        switch state {
        case .pausing(_, let episode), .playing(_, let episode):
            audioPlayer.currentTime = min(time, audioPlayer.duration - 1)
            guard let playingState = findOrCreatePlayingState(episodeID: episode.id) else {
                assertionFailure()
                return
            }
            try? playingState.move(to: time)
        case .notPlaying:
            assertionFailure()
        }
    }
    public func goForward(seconds: TimeInterval) {
        guard let audioPlayer else { return }
        move(to: audioPlayer.currentTime + seconds, audioPlayer: audioPlayer)
    }
    
    public func goBackward(seconds: TimeInterval) {
        guard let audioPlayer else { return }
        move(to: audioPlayer.currentTime - seconds, audioPlayer: audioPlayer)
    }
    
    private func findOrCreatePlayingState(episodeID: EpisodeRecord.ID) -> EpisodePlayingStateRecord? {
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
