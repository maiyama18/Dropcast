import Foundation

public struct Show: Sendable, Equatable {
    public var title: String
    public var description: String?
    public var author: String?
    public var imageURL: URL
    public var linkURL: URL?
    public var episodes: [Episode]

    public init(
        title: String,
        description: String?,
        author: String?,
        imageURL: URL,
        linkURL: URL?,
        episodes: [Episode]
    ) {
        self.title = title
        self.description = description
        self.author = author
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
        imageURL: URL(string: "https://cdn.rebuild.fm/images/icon1400.jpg")!,
        linkURL: URL(string: "https://rebuild.fm")!,
        // FIXME: fill episodes
        episodes: []
    )

    public static let fixtureSwiftBySundell = Show(
        title: "Swift by Sundell",
        description: "In-depth conversations about Swift and software development in general, hosted by John Sundell.",
        author: "John Sundell",
        imageURL: URL(string: "https://www.swiftbysundell.com/images/podcastArtwork.png")!,
        linkURL: URL(string: "https://www.swiftbysundell.com/podcast")!,
        // FIXME: fill episodes
        episodes: []
    )

    public static let fixtureプログラム雑談 = Show(
        title: "プログラム雑談",
        description: """
        プログラム雑談はkarino2が、主にプログラムに関わる事について、雑談するpodcastです。たまにプログラムと関係ない近況とかも話します。
        お便りはこちらから。 https://odaibako.net/u/karino2012
        """,
        author: "Kazuma Arino",
        imageURL: URL(string: "https://d3t3ozftmdmh3i.cloudfront.net/production/podcast_uploaded/998960/998960-1535212397504-93ed2911e3e38.jpg")!,
        linkURL: URL(string: "https://anchor.fm/karino2")!,
        // FIXME: fill episodes
        episodes: []
    )
}
#endif
