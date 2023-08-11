import AVFoundation
import CoreData
import Database
import Dependencies
import Entity
import Foundation
import Observation
import SoundFileState

@Observable
@MainActor
public final class SoundPlayerState: NSObject {
    public enum State: Equatable {
        case notPlaying
        case playing(episode: EpisodeRecord)
        case pausing(episode: EpisodeRecord)
    }
    
    public static let shared = SoundPlayerState()
    
    public var state: State = .notPlaying 
    public var currentTimeInt: Int?
    
    private var displayLink: CADisplayLink?
    private var audioPlayer: AVAudioPlayer? = nil
    private let context: NSManagedObjectContext = CloudKitPersistentProvider.shared.viewContext
    
    public func startPlaying(episode: EpisodeRecord) throws {
        // 別のファイルが再生中であれば pause する
        if case .playing(let episode) = state {
            pause(episode: episode)
        }
        
        let url = try SoundFileState.soundFileURL(episode: episode)
            
        let playingState = try? context.fetch(EpisodePlayingStateRecord.withEpisodeID(episode.id)).first
        
        let audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer.delegate = self
        audioPlayer.currentTime = playingState?.lastPausedTime ?? 0
        audioPlayer.play()
        self.audioPlayer = audioPlayer
        
        validateDisplayLink()
        
        self.state = .playing(episode: episode)
        
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
    
    public func pause(episode: EpisodeRecord) {
        audioPlayer?.stop()
        
        invalidateDisplayLink()
        
        self.state = .pausing(episode: episode)
        
        guard let playingState = findOrCreatePlayingState(episodeID: episode.id) else {
            assertionFailure()
            state = .notPlaying
            return
        }
        try? playingState.pause(atTime: audioPlayer?.currentTime ?? 0)
    }
    
    public func goForward(seconds: TimeInterval) {
        guard let audioPlayer else { return }
        move(to: audioPlayer.currentTime + seconds, audioPlayer: audioPlayer)
    }
    
    public func goBackward(seconds: TimeInterval) {
        guard let audioPlayer else { return }
        move(to: audioPlayer.currentTime - seconds, audioPlayer: audioPlayer)
    }
    
    private func move(to time: TimeInterval, audioPlayer: AVAudioPlayer) {
        switch state {
        case .pausing(let episode), .playing(let episode):
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
    
    private func validateDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateCurrentTimeInt))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func invalidateDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateCurrentTimeInt() {
        currentTimeInt = Int(audioPlayer?.currentTime ?? 0)
    }
    
}

extension SoundPlayerState: AVAudioPlayerDelegate {
    nonisolated public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
    }
    
    nonisolated public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }
}
