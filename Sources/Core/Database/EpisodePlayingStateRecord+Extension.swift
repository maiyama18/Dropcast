import CoreData
import Dependencies

extension EpisodePlayingStateRecord {
    public static func withEpisodeID(_ episodeID: String) -> NSFetchRequest<EpisodePlayingStateRecord> {
        let request = EpisodePlayingStateRecord.fetchRequest()
        request.predicate = NSPredicate(format: "episode.id == %@", episodeID)
        return request
    }
    
    public func startPlaying(atTime: TimeInterval) throws {
        struct RecordNotFound: Error {}
        
        @Dependency(\.date.now) var now
        
        guard let episode else { throw RecordNotFound() }
        isPlaying = true
        willFinishedAt = now.addingTimeInterval(episode.duration - atTime)
        lastPausedTime = 0
    }
    
    public func pause(atTime: TimeInterval) {
        isPlaying = false
        willFinishedAt = nil
        lastPausedTime = atTime
    }
}
