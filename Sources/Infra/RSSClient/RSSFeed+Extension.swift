import Entity
import FeedKit
import Foundation

extension RSSFeed {
    func toShow(feedURL: URL) -> Show? {
        guard let title = title?.trimmingCharacters(in: .whitespacesAndNewlines),
              let imageURL = URL(string: image?.url ?? "") ?? URL(string: iTunes?.iTunesImage?.attributes?.href ?? ""),
              let items else {
            return nil
        }

        let episodes: [Episode] = items.compactMap { item -> Episode? in
            guard let guid = item.guid?.value,
                  let title = item.title?.trimmingCharacters(in: .whitespacesAndNewlines),
                  let duration = item.iTunes?.iTunesDuration,
                  let publishedAt = item.pubDate,
                  let soundURL = URL(string: item.enclosure?.attributes?.url ?? "") else {
                return nil
            }

            return Episode(
                id: guid,
                title: title,
                subtitle: (item.iTunes?.iTunesSubtitle ?? item.iTunes?.iTunesSummary)?.trimmingCharacters(in: .newlines).trimmingCharacters(in: .whitespacesAndNewlines),
                description: (item.content?.contentEncoded ?? item.description)?.trimmingCharacters(in: .newlines).trimmingCharacters(in: .whitespacesAndNewlines),
                duration: duration,
                soundURL: soundURL,
                publishedAt: publishedAt,
                showFeedURL: feedURL,
                showTitle: title,
                showImageURL: imageURL
            )
        }

        return Show(
            title: title,
            description: (description ?? iTunes?.iTunesSummary)?.trimmingCharacters(in: .newlines).trimmingCharacters(in: .whitespaces),
            author: iTunes?.iTunesAuthor ?? iTunes?.iTunesOwner?.name,
            feedURL: feedURL,
            imageURL: imageURL,
            linkURL: URL(string: link ?? ""),
            episodes: episodes
        )
    }
}
