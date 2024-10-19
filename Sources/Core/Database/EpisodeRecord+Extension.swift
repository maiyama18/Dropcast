import CoreData
import Formatter
import SwiftUI

extension EpisodeRecord {
    @MainActor
    public static func withID(_ id: String) -> NSFetchRequest<EpisodeRecord> {
        let request = EpisodeRecord.fetchRequest()
        request.predicate = NSPredicate(format: "id_ == %@", id)
        return request
    }

    @MainActor
    public static func followed() -> NSFetchRequest<EpisodeRecord> {
        let request = EpisodeRecord.fetchRequest()
        request.predicate = NSPredicate(format: "followed = %@", NSNumber(value: true))
        request.sortDescriptors = [.init(keyPath: \EpisodeRecord.publishedAt_, ascending: false)]
        return request
    }

    public static func withShowFeedURL(_ url: URL) -> NSFetchRequest<EpisodeRecord> {
        let request = EpisodeRecord.fetchRequest()
        request.predicate = NSPredicate(format: "show.feedURL_ == %@", url as CVarArg)
        request.sortDescriptors = [.init(keyPath: \EpisodeRecord.publishedAt_, ascending: false)]
        return request
    }

    public var id: String { id_ ?? "" }
    public var title: String { title_ ?? "" }
    public var soundURL: URL { soundURL_! }
    public var publishedAt: Date { publishedAt_ ?? .now }

    public convenience init(
        context: NSManagedObjectContext = PersistentProvider.cloud.viewContext,
        id: String,
        title: String,
        subtitle: String?,
        description: String?,
        duration: Double,
        soundURL: URL,
        publishedAt: Date
    ) {
        self.init(context: context)

        self.id_ = id
        self.title_ = title
        self.subtitle = subtitle
        self.episodeDescription = description
        self.duration = duration
        self.soundURL_ = soundURL
        self.publishedAt_ = publishedAt
    }
}

extension EpisodeRecord {
    public static func fixture(context: NSManagedObjectContext) -> EpisodeRecord {
        let episode = EpisodeRecord(
            context: context,
            id: "https://rebuild.fm/352/",
            title: "352: There's a Fifth Way (naoya)",
            subtitle: "Naoya Ito さんをゲストに迎えて、MacBook Pro, キーボード、競技プログラミング、レイオフ、ゲームなどについて話しました。",
            description: """
            <p>Naoya Ito さんをゲストに迎えて、MacBook Pro, キーボード、競技プログラミング、レイオフ、ゲームなどについて話しました。</p>
            <h3>Show Notes</h3><ul>
            <li><a href="https://www.apple.com/macbook-pro-14-and-16/">MacBook Pro</a></li>
            <li><a href="https://www.intel.com/content/www/us/en/products/details/nuc.html">Intel® NUC</a></li>
            </ul>
            """,
            duration: 1000,
            soundURL: URL(string: "https://example.com")!,
            publishedAt: rssDateFormatter.date(from: "Tue, 03 Jan 2023 20:00:00 -0800")!
        )

        episode.show = ShowRecord(
            context: context,
            title: "Rebuild",
            description: "ウェブ開発、プログラミング、モバイル、ガジェットなどにフォーカスしたテクノロジー系ポッドキャストです。 #rebuildfm",
            author: "Tatsuhiko Miyagawa",
            feedURL: URL(string: "https://feeds.rebuild.fm/rebuildfm")!,
            imageURL: URL(string: "https://cdn.rebuild.fm/images/icon1400.jpg")!,
            linkURL: URL(string: "https://rebuild.fm")
        )

        return episode
    }
}
