import Entity
import FeedKit
import Foundation

extension RSSFeed {
    func toShow() -> Show? {
        guard let title = title,
              let imageURL = URL(string: image?.url ?? "") ?? URL(string: iTunes?.iTunesImage?.attributes?.href ?? ""),
              let items else {
            return nil
        }

        let episodes: [Episode] = items.compactMap { item -> Episode? in
            guard let guid = item.guid?.value,
                  let title = item.title,
                  let duration = item.iTunes?.iTunesDuration,
                  let soundURL = URL(string: item.enclosure?.attributes?.url ?? "") else {
                return nil
            }
            return Episode(
                guid: guid,
                title: title,
                subtitle: (item.iTunes?.iTunesSubtitle ?? item.iTunes?.iTunesSummary)?.trimmingCharacters(in: .newlines).trimmingCharacters(in: .whitespaces),
                description: (item.content?.contentEncoded ?? item.description)?.trimmingCharacters(in: .newlines).trimmingCharacters(in: .whitespaces),
                duration: duration,
                soundURL: soundURL
            )
        }

        return Show(
            title: title,
            description: (description ?? iTunes?.iTunesSummary)?.trimmingCharacters(in: .newlines).trimmingCharacters(in: .whitespaces),
            author: iTunes?.iTunesAuthor ?? iTunes?.iTunesOwner?.name,
            imageURL: imageURL,
            linkURL: URL(string: link ?? ""),
            episodes: episodes
        )
    }
}
