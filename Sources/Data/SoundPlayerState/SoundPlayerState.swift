import AVFoundation
import Dependencies
import Entity
import Foundation
import Observation

@Observable
public final class SoundPlayerState: NSObject {
    public enum State {
        case notPlaying
        case playing(url: URL, episode: Episode)
        case pausing(episode: Episode)
    }
    
    public static let shared = SoundPlayerState()
    
    public var state: State = .notPlaying
    
    private var audioPlayer: AVAudioPlayer? = nil
    
    public func startPlaying(url: URL, episode: Episode) throws {
        let audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer.delegate = self
        audioPlayer.play()
        self.audioPlayer = audioPlayer
        
        self.state = .playing(url: url, episode: episode)
    }
    
    public func pause(episode: Episode) {
        guard let audioPlayer, audioPlayer.isPlaying else { return }
        audioPlayer.pause()
        
        self.state = .pausing(episode: episode)
    }
}

extension SoundPlayerState: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
    }
    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }
}
