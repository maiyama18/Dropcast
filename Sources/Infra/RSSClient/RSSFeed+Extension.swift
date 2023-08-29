import FeedKit
import Foundation

extension RSSFeed {
    func toShow(feedURL: URL) -> RSSShow? {
        guard let title = title?.trimmingCharacters(in: .whitespacesAndNewlines),
              let imageURL = URL(string: image?.url ?? "") ?? URL(string: iTunes?.iTunesImage?.attributes?.href ?? ""),
              let items else {
            return nil
        }

        let episodes: [RSSEpisode] = items.compactMap { item -> RSSEpisode? in
            guard let guid = item.guid?.value,
                  let title = item.title?.trimmingCharacters(in: .whitespacesAndNewlines),
                  let duration = item.iTunes?.iTunesDuration,
                  let publishedAt = item.pubDate,
                  let soundURL = URL(string: item.enclosure?.attributes?.url ?? "") else {
                return nil
            }

            return RSSEpisode(
                id: guid,
                title: title,
                soundURL: soundURL,
                duration: duration,
                publishedAt: publishedAt,
                subtitle: (item.iTunes?.iTunesSubtitle ?? item.iTunes?.iTunesSummary)?.trimmingCharacters(in: .newlines).trimmingCharacters(in: .whitespacesAndNewlines),
                description: (item.content?.contentEncoded ?? item.description)?.trimmingCharacters(in: .newlines).trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }

        return RSSShow(
            feedURL: feedURL,
            title: title,
            imageURL: imageURL,
            description: (description ?? iTunes?.iTunesSummary)?.trimmingCharacters(in: .newlines).trimmingCharacters(in: .whitespaces),
            author: iTunes?.iTunesAuthor ?? iTunes?.iTunesOwner?.name,
            linkURL: URL(string: link ?? ""),
            episodes: episodes
        )
    }
}
