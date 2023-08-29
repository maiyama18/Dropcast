import AVFoundation
import CoreData
import Database
import Dependencies
import Entity
import Foundation
import HapticClient
import MediaPlayer
import Observation
import PodcastChapterExtractUseCase
import SoundFileState
import UserDefaultsClient

@Observable
@MainActor
public final class SoundPlayerState: NSObject {
    public enum State: Equatable {
        case notPlaying
        case playing(episode: EpisodeRecord)
        case pausing(episode: EpisodeRecord)
        
        public var isPlayingOrPausing: Bool {
            playingEpisode != nil
        }
        
        public var playingEpisode: EpisodeRecord? {
            switch self {
            case .notPlaying:
                return nil
            case .playing(let episode), .pausing(let episode):
                return episode
            }
        }
    }
        
    public enum SpeedRate: Float, CaseIterable {
        case _0_5 = 0.5
        case _0_75 = 0.75
        case _1 = 1
        case _1_25 = 1.25
        case _1_5 = 1.5
        case _1_75 = 1.75
        
        public var formatted: String {
            switch self {
            case ._0_5: return "0.5x"
            case ._0_75: return "0.75x"
            case ._1: return "1.0x"
            case ._1_25: return "1.25x"
            case ._1_5: return "1.5x"
            case ._1_75: return "1.75x"
            }
        }
    }

    public static let shared = SoundPlayerState()
    
    @ObservationIgnored @Dependency(\.hapticClient) private var hapticClient
    @ObservationIgnored @Dependency(\.userDefaultsClient) private var userDefaultsClient
    @ObservationIgnored @Dependency(\.podcastChapterExtractUseCase) private var podcastChapterExtractUseCase
    
    public var state: State = .notPlaying 
    public var currentTimeInt: Int?
    public var duration: Double?
    public var speedRate: SpeedRate = ._1 {
        didSet {
            audioPlayer?.rate = speedRate.rawValue
            userDefaultsClient.setSoundPlayerSpeedRate(speedRate.rawValue)
        }
    }
    public var chapters: [Chapter] = []
    public var currentChapter: Chapter? {
        guard let currentTimeInt else { return nil }
        return chapters.first(where: { Double(currentTimeInt) >= $0.startsAt && Double(currentTimeInt) < $0.endsAt })
    }
    public var currentChapterProgress: Double {
        guard let currentChapter, let currentTimeInt else { return 0 }
        let progress = (Double(currentTimeInt) - currentChapter.startsAt) / currentChapter.duration
        return max(min(progress, 1), 0)
    }
    
    private var displayLink: CADisplayLink?
    private var audioPlayer: AVAudioPlayer? = nil
    private let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext = PersistentProvider.cloud.viewContext) {
        self.context = context
        super.init()
        
        self.speedRate = SpeedRate(rawValue: userDefaultsClient.getSoundPlayerSpeedRate() ?? 1) ?? ._1
        restoreCurrentState()
        configureRemoteCommands()
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }
    
    private func configureRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()
        
        center.playCommand.isEnabled = true
        center.playCommand.removeTarget(self)
        center.playCommand.addTarget { [weak self] _ in
            guard let self else { return .noActionableNowPlayingItem }
            switch state {
            case .notPlaying:
                return .noActionableNowPlayingItem
            case .playing(let episode), .pausing(let episode):
                do {
                    try startPlaying(episode: episode)
                    return .success
                } catch {
                    return .commandFailed
                }
            }
        }
        
        center.pauseCommand.isEnabled = true
        center.pauseCommand.removeTarget(self)
        center.pauseCommand.addTarget { [weak self] _ in
            guard let self else { return .noActionableNowPlayingItem }
            switch state {
            case .notPlaying:
                return .noActionableNowPlayingItem
            case .playing(let episode), .pausing(let episode):
                pause(episode: episode)
                return .success
            }
        }
        
        center.skipForwardCommand.isEnabled = true
        center.skipForwardCommand.preferredIntervals = [10.0]
        center.skipForwardCommand.removeTarget(self)
        center.skipForwardCommand.addTarget { [weak self] _ in
            guard let self else { return .noActionableNowPlayingItem }
            goForward(seconds: 10)
            return .success
        }
        
        center.skipBackwardCommand.isEnabled = true
        center.skipBackwardCommand.preferredIntervals = [10.0]
        center.skipBackwardCommand.removeTarget(self)
        center.skipBackwardCommand.addTarget { [weak self] _ in
            guard let self else { return .noActionableNowPlayingItem }
            goBackward(seconds: 10)
            return .success
        }
    }
    
    private func updateNowPlayingInfo() {
        let episode: EpisodeRecord
        switch state {
        case .notPlaying:
            return
        case .playing(let e), .pausing(let e):
            episode = e
        }
        
        var nowPlayingInfo: [String: Any] = [
            MPNowPlayingInfoPropertyPlaybackRate: speedRate.rawValue,
            MPMediaItemPropertyTitle: episode.title,
            MPMediaItemPropertyMediaType: MPMediaType.anyAudio.rawValue,
        ]
        if let audioPlayer {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = audioPlayer.duration
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime
        }
        if let show = episode.show {
            nowPlayingInfo[MPMediaItemPropertyArtist] = show.title
            nowPlayingInfo[MPMediaItemPropertyPodcastTitle] = show.title
            
            let imageURL = show.imageURL
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: .init(width: 600, height: 600)) { _ in
                guard let data = try? Data(contentsOf: imageURL) else {
                    return UIImage()
                }
                return UIImage(data: data) ?? UIImage()
            }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func storeCurrentState() {
        let episodeID: EpisodeRecord.ID
        switch state {
        case .notPlaying:
            return
        case .playing(let episode), .pausing(let episode):
            episodeID = episode.id
        }
        
        userDefaultsClient.setStoredSoundPlayerState(episodeID, audioPlayer?.currentTime ?? 0)
    }
    
    private func restoreCurrentState() {
        guard let storedSoundPlayerState = userDefaultsClient.getStoredSoundPlayerState(),
              let episode = try? context.fetch(EpisodeRecord.withID(storedSoundPlayerState.episodeID)).first,
              let playingState = episode.playingState else {
            state = .notPlaying
            return
        }
        
        do {
            try playingState.pause(atTime: storedSoundPlayerState.currentTime)
            currentTimeInt = Int(storedSoundPlayerState.currentTime)
            duration = episode.duration
            
            state = .pausing(episode: episode)
            
            let url = try SoundFileState.soundFileURL(episode: episode)
            
            self.audioPlayer = try configureAudioPlayer(url: url, currentTime: storedSoundPlayerState.currentTime)
            
            updateNowPlayingInfo()
            
            Task {
                chapters = try await podcastChapterExtractUseCase.extract(url)
            }
        } catch {
            state = .notPlaying
        }
    }
    
    public func startPlaying(episode: EpisodeRecord) throws {
        hapticClient.medium()
        
        // 別のファイルが再生中であれば pause する
        if case .playing(let episode) = state {
            pause(episode: episode)
        }
        
        let url = try SoundFileState.soundFileURL(episode: episode)
            
        let playingState = try? context.fetch(EpisodePlayingStateRecord.withEpisodeID(episode.id)).first
        
        let audioPlayer = try configureAudioPlayer(url: url, currentTime: playingState?.lastPausedTime ?? 0)
        self.audioPlayer = audioPlayer
        audioPlayer.play()
        self.duration = audioPlayer.duration
        
        validateDisplayLink()
        
        self.state = .playing(episode: episode)
        updateNowPlayingInfo()
        
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
        
        Task {
            chapters = try await podcastChapterExtractUseCase.extract(url)
        }
    }
    
    public func pause(episode: EpisodeRecord) {
        hapticClient.medium()
        
        audioPlayer?.stop()
        
        invalidateDisplayLink()
        
        self.state = .pausing(episode: episode)
        updateNowPlayingInfo()
        
        guard let playingState = findOrCreatePlayingState(episodeID: episode.id) else {
            assertionFailure()
            state = .notPlaying
            return
        }
        try? playingState.pause(atTime: audioPlayer?.currentTime ?? 0)
        storeCurrentState()
    }
    
    public func goForward(seconds: TimeInterval) {
        guard let currentTime = audioPlayer?.currentTime else { return }
        hapticClient.medium()
        move(to: currentTime + seconds)
    }
    
    public func goBackward(seconds: TimeInterval) {
        guard let currentTime = audioPlayer?.currentTime else { return }
        hapticClient.medium()
        move(to: currentTime - seconds)
    }
    
    public func goToChapter(chapter: Chapter) {
        move(to: chapter.startsAt + 0.5)
    }
    
    public func move(to time: TimeInterval) {
        guard let audioPlayer else { return }
        switch state {
        case .pausing(let episode), .playing(let episode):
            let clampedTime = max(min(time, audioPlayer.duration - 1), 0)
            audioPlayer.currentTime = clampedTime
            guard let playingState = findOrCreatePlayingState(episodeID: episode.id) else {
                assertionFailure()
                return
            }
            try? playingState.move(to: clampedTime)
            var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = clampedTime
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            didDisplayLinkTick()
            
            Task {
                let url = try SoundFileState.soundFileURL(episode: episode)
                chapters = try await podcastChapterExtractUseCase.extract(url)
            }
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
        displayLink = CADisplayLink(target: self, selector: #selector(didDisplayLinkTick))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func invalidateDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    private func configureAudioPlayer(url: URL, currentTime: TimeInterval) throws -> AVAudioPlayer {
        let audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer.delegate = self
        audioPlayer.enableRate = true
        audioPlayer.rate = speedRate.rawValue
        audioPlayer.currentTime = currentTime
        return audioPlayer
    }
    
    @objc private func didDisplayLinkTick() {
        currentTimeInt = Int(audioPlayer?.currentTime ?? 0)
        storeCurrentState()
    }
    
    @objc private func handleInterruption() {
        if case .playing(let episode) = state {
            pause(episode: episode)
        }
    }
}

extension SoundPlayerState: AVAudioPlayerDelegate {
    nonisolated public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.stop()
        Task { @MainActor in
            self.audioPlayer = nil
            self.duration = nil
            invalidateDisplayLink()
            
            defer { state = .notPlaying }
            guard case .playing(let episode) = state,
                  let playingState = episode.playingState else {
                return
            }
            
            try? playingState.complete()
        }
    }
    
    nonisolated public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        player.stop()
        Task { @MainActor in
            self.audioPlayer = nil
            invalidateDisplayLink()
            
            defer { state = .notPlaying }
            guard case .playing(let episode) = state,
                  let playingState = episode.playingState else {
                return
            }
            
            playingState.managedObjectContext?.delete(playingState)
        }
    }
}
