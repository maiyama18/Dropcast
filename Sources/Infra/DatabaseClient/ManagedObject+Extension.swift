import CoreData
import Dependencies
import Entity
import SwiftUI

extension ShowRecord {
    @MainActor
    public static func withFeedURL(_ feedURL: URL) -> FetchRequest<ShowRecord> {
        FetchRequest<ShowRecord>(
            entity: ShowRecord.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "%K == %@", #keyPath(ShowRecord.feedURL), feedURL as CVarArg)
        )
    }
    
    public convenience init(context: NSManagedObjectContext, show: Show) {
        self.init(context: context)

        title = show.title
        showDescription = show.description
        author = show.author
        feedURL = show.feedURL
        imageURL = show.imageURL
        linkURL = show.linkURL
        episodes = NSSet(
            array: show.episodes.map {
                EpisodeRecord(context: context, episode: $0)
            }
        )
    }

    public func toEntity() -> Show? {
        guard let title,
              let feedURL,
              let imageURL else { return nil }

        return Show(
            title: title,
            description: showDescription,
            author: author,
            feedURL: feedURL,
            imageURL: imageURL,
            linkURL: linkURL,
            episodes: episodes?.compactMap { ($0 as? EpisodeRecord)?.toEntity() }.sorted(by: { $0.publishedAt > $1.publishedAt }) ?? []
        )
    }
}

extension EpisodeRecord {
    public static func withID(_ id: String) -> NSFetchRequest<EpisodeRecord> {
        let request = EpisodeRecord.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        return request
    }
    
    public convenience init(context: NSManagedObjectContext, episode: Episode) {
        self.init(context: context)

        id = episode.id
        title = episode.title
        subtitle = episode.subtitle
        episodeDescription = episode.description
        duration = episode.duration
        soundURL = episode.soundURL
        publishedAt = episode.publishedAt
    }

    public convenience init(context: NSManagedObjectContext, episode: Episode, show: Show) {
        self.init(context: context, episode: episode)
        self.show = ShowRecord(context: context, show: show)
    }

    public func toEntity() -> Episode? {
        guard let id,
              let title,
              let soundURL,
              let publishedAt,
              let showFeedURL = show?.feedURL,
              let showTitle = show?.title,
              let showImageURL = show?.imageURL else { return nil }

        return Episode(
            id: id,
            title: title,
            subtitle: subtitle,
            description: episodeDescription,
            duration: duration,
            soundURL: soundURL,
            publishedAt: publishedAt,
            showFeedURL: showFeedURL,
            showTitle: showTitle,
            showImageURL: showImageURL
        )
    }
}

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
