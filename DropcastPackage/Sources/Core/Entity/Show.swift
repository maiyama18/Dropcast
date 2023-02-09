import Foundation

public struct Show: Sendable, Equatable, Identifiable {
    public var title: String
    public var description: String?
    public var author: String?
    public var feedURL: URL
    public var imageURL: URL
    public var linkURL: URL?
    public var episodes: [Episode]

    public var id: URL { feedURL }

    public init(
        title: String,
        description: String?,
        author: String?,
        feedURL: URL,
        imageURL: URL,
        linkURL: URL?,
        episodes: [Episode]
    ) {
        self.title = title
        self.description = description
        self.author = author
        self.feedURL = feedURL
        self.imageURL = imageURL
        self.linkURL = linkURL
        self.episodes = episodes
    }
}

#if DEBUG
extension Show {
    public static let fixtureRebuild = Show(
        title: "Rebuild",
        description: "ウェブ開発、プログラミング、モバイル、ガジェットなどにフォーカスしたテクノロジー系ポッドキャストです。 #rebuildfm",
        author: "Tatsuhiko Miyagawa",
        feedURL: URL(string: "https://feeds.rebuild.fm/rebuildfm")!,
        imageURL: URL(string: "https://cdn.rebuild.fm/images/icon1400.jpg")!,
        linkURL: URL(string: "https://rebuild.fm")!,
        episodes: [
            .fixtureRebuild352,
            .fixtureRebuild351,
            .fixtureRebuild350,
        ]
    )

    public static let fixtureSwiftBySundell = Show(
        title: "Swift by Sundell",
        description: "In-depth conversations about Swift and software development in general, hosted by John Sundell.",
        author: "John Sundell",
        feedURL: URL(string: "https://www.swiftbysundell.com/podcast/feed.rss")!,
        imageURL: URL(string: "https://www.swiftbysundell.com/images/podcastArtwork.png")!,
        linkURL: URL(string: "https://www.swiftbysundell.com/podcast")!,
        episodes: [
            .fixtureSwiftBySundell123,
            .fixtureSwiftBySundell122,
            .fixtureSwiftBySundell121,
        ]
    )

    public static let fixtureプログラム雑談 = Show(
        title: "プログラム雑談",
        description: """
        プログラム雑談はkarino2が、主にプログラムに関わる事について、雑談するpodcastです。たまにプログラムと関係ない近況とかも話します。
        お便りはこちらから。 https://odaibako.net/u/karino2012
        """,
        author: "Kazuma Arino",
        feedURL: URL(string: "https://anchor.fm/s/68ce140/podcast/rss")!,
        imageURL: URL(string: "https://d3t3ozftmdmh3i.cloudfront.net/production/podcast_uploaded/998960/998960-1535212397504-93ed2911e3e38.jpg")!,
        linkURL: URL(string: "https://anchor.fm/karino2")!,
        episodes: [
            .fixtureプログラム雑談225,
            .fixtureプログラム雑談224,
            .fixtureプログラム雑談223,
        ]
    )
}
#endif
