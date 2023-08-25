import CoreData
import Dependencies

extension EpisodePlayingStateRecord: Model {}

extension EpisodePlayingStateRecord {
    struct RecordNotFound: Error {}
    
    public static func withEpisodeID(_ episodeID: String) -> NSFetchRequest<EpisodePlayingStateRecord> {
        let request = EpisodePlayingStateRecord.fetchRequest()
        request.predicate = NSPredicate(format: "episode.id_ == %@", episodeID)
        return request
    }
    
    @MainActor
    public func startPlaying(atTime: TimeInterval) throws {
        @Dependency(\.date.now) var now
        
        guard let episode else { throw RecordNotFound() }
        isCompleted = false
        isPlaying = true
        willFinishedAt = now.addingTimeInterval(episode.duration - atTime)
        lastPausedTime = 0
        
        try save()
    }
    
    @MainActor
    public func pause(atTime: TimeInterval) throws {
        isPlaying = false
        willFinishedAt = nil
        lastPausedTime = atTime
        
        try save()
    }
    
    @MainActor
    public func move(to time: TimeInterval) throws {
        @Dependency(\.date.now) var now
        
        guard let episode else { throw RecordNotFound() }
        if isPlaying {
            willFinishedAt = now.addingTimeInterval(episode.duration - time)
        } else {
            lastPausedTime = time
        }
        
        try save()
    }
    
    @MainActor
    public func complete() throws {
        isPlaying = false
        isCompleted = true
        willFinishedAt = nil
        lastPausedTime = 0
        
        try save()
    }
}
