import CoreData
import Entity

extension ShowRecord {
    convenience init(context: NSManagedObjectContext, show: Show) {
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

    func toShow() -> Show? {
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
            episodes: episodes?.compactMap { ($0 as? EpisodeRecord)?.toEpisode() } ?? []
        )
    }
}

extension EpisodeRecord {
    convenience init(context: NSManagedObjectContext, episode: Episode) {
        self.init(context: context)

        guid = episode.guid
        title = episode.title
        subtitle = episode.subtitle
        episodeDescription = episode.description
        duration = episode.duration
        soundURL = episode.soundURL
    }

    func toEpisode() -> Episode? {
        guard let guid,
              let title,
              let soundURL,
              let publishedAt,
              let showFeedURL = show?.feedURL,
              let showTitle = show?.title else { return nil }

        return Episode(
            guid: guid,
            title: title,
            subtitle: subtitle,
            description: episodeDescription,
            duration: duration,
            soundURL: soundURL,
            publishedAt: publishedAt,
            showFeedURL: showFeedURL,
            showTitle: showTitle
        )
    }
}
