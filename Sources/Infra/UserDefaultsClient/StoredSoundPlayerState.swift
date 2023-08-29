import Defaults
import Foundation

public struct StoredSoundPlayerState: Codable, Defaults.Serializable {
    public init(episodeID: String, currentTime: TimeInterval) {
        self.episodeID = episodeID
        self.currentTime = currentTime
    }
    
    public var episodeID: String
    public var currentTime: TimeInterval
}
