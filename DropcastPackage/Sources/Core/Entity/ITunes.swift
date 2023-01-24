import Foundation

public struct Show: Sendable, Equatable, Identifiable {
    public var id: Int
    public var artistName: String
    public var showName: String
    public var genreName: String
    public var feedURL: URL
    public var storeURL: URL
    public var artworkURL: URL

    public init(
        id: Int,
        artistName: String,
        showName: String,
        genreName: String,
        feedURL: URL,
        storeURL: URL,
        artworkURL: URL
    ) {
        self.id = id
        self.artistName = artistName
        self.showName = showName
        self.genreName = genreName
        self.feedURL = feedURL
        self.storeURL = storeURL
        self.artworkURL = artworkURL
    }
}

#if DEBUG
extension Show {
    public static let fixtureStackOverflow = Show(
        id: 1483510527,
        artistName: "The Stack Overflow Podcast",
        showName: "The Stack Overflow Podcast",
        genreName: "Technology",
        feedURL: URL(string: "https://feeds.simplecast.com/XA_851k3")!,
        storeURL: URL(string: "https://podcasts.apple.com/us/podcast/the-stack-overflow-podcast/id1483510527?uo=4")!,
        artworkURL: URL(string: "https://is4-ssl.mzstatic.com/image/thumb/Podcasts116/v4/6d/32/15/"
                        + "6d32155b-12ec-8d15-2f76-256e8e7f8dcf/mza_16949506039235574720.jpg/600x600bb.jpg")!
    )

    public static let fixtureNature = Show(
        id: 81934659,
        artistName: "Springer Nature Limited",
        showName: "Nature Podcast",
        genreName: "Science",
        feedURL: URL(string: "http://rss.acast.com/nature")!,
        storeURL: URL(string: "https://podcasts.apple.com/us/podcast/nature-podcast/id81934659?uo=4")!,
        artworkURL: URL(string: "https://is4-ssl.mzstatic.com/image/thumb/Podcasts116/v4/b0/56/82/"
                        + "b05682ce-9ea4-5344-bb60-88507456c327/mza_14062456357964887097.jpg/600x600bb.jpg")!)

    public static let fixtureRebuild = Show(
        id: 81934659,
        artistName: "Tatsuhiko Miyagawa",
        showName: "Rebuild",
        genreName: "Technology",
        feedURL: URL(string: "https://feeds.rebuild.fm/rebuildfm")!,
        storeURL: URL(string: "https://podcasts.apple.com/us/podcast/rebuild/id603013428?uo=4")!,
        artworkURL: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Podcasts125/v4/d6/20/fe/"
                        + "d620fea4-8f14-8402-1041-0388a31720e6/mza_1949949944137970976.jpg/600x600bb.jpg")!)

    public static let fixtureStacktrace = Show(
        id: 81934659,
        artistName: "John Sundell and Gui Rambo",
        showName: "Stacktrace",
        genreName: "Technology",
        feedURL: URL(string: "https://stacktracepodcast.fm/feed.rss")!,
        storeURL: URL(string: "https://podcasts.apple.com/us/podcast/stacktrace/id1359435443?uo=4")!,
        artworkURL: URL(string: "https://is4-ssl.mzstatic.com/image/thumb/Podcasts122/v4/21/b1/83/"
                        + "21b183f6-53e2-fe5e-eabb-f7447577c9b7/mza_9137980121963783437.png/600x600bb.jpg")!)
}

#endif
