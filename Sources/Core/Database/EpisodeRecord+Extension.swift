import CoreData
import Formatter

extension EpisodeRecord: Model {}

extension EpisodeRecord {
    public static func withID(_ id: String) -> NSFetchRequest<EpisodeRecord> {
        let request = EpisodeRecord.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        return request
    }
    
    public var id: String { id_! }
    public var title: String { title_! }
    public var soundURL: URL { soundURL_! }
    public var publishedAt: Date { publishedAt_! }
    
    public convenience init(
        context: NSManagedObjectContext? = nil,
        id: String,
        title: String,
        subtitle: String?,
        description: String?,
        duration: Double,
        soundURL: URL,
        publishedAt: Date
    ) {
        if let context {
            self.init(context: context)
        } else {
            self.init(entity: CloudKitPersistentProvider.shared.managedObjectModel.entitiesByName["EpisodeRecord"]!, insertInto: nil)
        }
        
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
    public static var fixture: EpisodeRecord {
        EpisodeRecord(
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
    }
}
