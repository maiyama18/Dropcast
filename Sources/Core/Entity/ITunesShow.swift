import Foundation

public struct ITunesShow: Sendable, Equatable, Identifiable {
    public var id: Int
    public var artistName: String
    public var showName: String
    public var feedURL: URL
    public var artworkURL: URL
    public var artworkLowQualityURL: URL

    public init(
        id: Int,
        artistName: String,
        showName: String,
        feedURL: URL,
        artworkURL: URL,
        artworkLowQualityURL: URL
    ) {
        self.id = id
        self.artistName = artistName
        self.showName = showName
        self.feedURL = feedURL
        self.artworkURL = artworkURL
        self.artworkLowQualityURL = artworkLowQualityURL
    }
}

#if DEBUG
extension ITunesShow {
    public static let fixtureStackOverflow = ITunesShow(
        id: 1483510527,
        artistName: "The Stack Overflow Podcast",
        showName: "The Stack Overflow Podcast",
        feedURL: URL(string: "https://feeds.simplecast.com/XA_851k3")!,
        artworkURL: URL(string: "https://is4-ssl.mzstatic.com/image/thumb/Podcasts116/v4/6d/32/15/"
                            + "6d32155b-12ec-8d15-2f76-256e8e7f8dcf/mza_16949506039235574720.jpg/600x600bb.jpg")!,
        artworkLowQualityURL: URL(string: "https://is4-ssl.mzstatic.com/image/thumb/Podcasts116/v4/6d/32/15/"
                                    + "6d32155b-12ec-8d15-2f76-256e8e7f8dcf/mza_16949506039235574720.jpg/100x100bb.jpg")!
    )

    public static let fixtureNature = ITunesShow(
        id: 81934659,
        artistName: "Springer Nature Limited",
        showName: "Nature Podcast",
        feedURL: URL(string: "http://rss.acast.com/nature")!,
        artworkURL: URL(string: "https://is4-ssl.mzstatic.com/image/thumb/Podcasts116/v4/b0/56/82/"
                            + "b05682ce-9ea4-5344-bb60-88507456c327/mza_14062456357964887097.jpg/600x600bb.jpg")!,
        artworkLowQualityURL: URL(string: "https://is4-ssl.mzstatic.com/image/thumb/Podcasts116/v4/b0/56/82/"
                                    + "b05682ce-9ea4-5344-bb60-88507456c327/mza_14062456357964887097.jpg/100x100bb.jpg")!
    )

    public static let fixtureRebuild = ITunesShow(
        id: 81934650,
        artistName: "Tatsuhiko Miyagawa",
        showName: "Rebuild",
        feedURL: URL(string: "https://feeds.rebuild.fm/rebuildfm")!,
        artworkURL: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Podcasts125/v4/d6/20/fe/"
                            + "d620fea4-8f14-8402-1041-0388a31720e6/mza_1949949944137970976.jpg/600x600bb.jpg")!,
        artworkLowQualityURL: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Podcasts125/v4/d6/20/fe/"
                                    + "d620fea4-8f14-8402-1041-0388a31720e6/mza_1949949944137970976.jpg/100x100bb.jpg")!
    )

    public static let fixtureStacktrace = ITunesShow(
        id: 81934619,
        artistName: "John Sundell and Gui Rambo",
        showName: "Stacktrace",
        feedURL: URL(string: "https://stacktracepodcast.fm/feed.rss")!,
        artworkURL: URL(string: "https://is4-ssl.mzstatic.com/image/thumb/Podcasts122/v4/21/b1/83/"
                            + "21b183f6-53e2-fe5e-eabb-f7447577c9b7/mza_9137980121963783437.png/600x600bb.jpg")!,
        artworkLowQualityURL: URL(string: "https://is4-ssl.mzstatic.com/image/thumb/Podcasts122/v4/21/b1/83/"
                                    + "21b183f6-53e2-fe5e-eabb-f7447577c9b7/mza_9137980121963783437.png/100x100bb.jpg")!
    )

    public static let fixtureBilingualNews = ITunesShow(
        id: 81934620,
        artistName: "Michael & Mami",
        showName: "バイリンガルニュース (Bilingual News)",
        feedURL: URL(string: "https://bilingualnews.libsyn.com/rss")!,
        artworkURL: URL(string: "https://is2-ssl.mzstatic.com/image/thumb/Podcasts115/v4/d8/68/49/"
                            + "d868497c-f3b5-f40d-00d7-514cbdc3ac8b/mza_12097083422146527699.jpg/600x600bb.jpg")!,
        artworkLowQualityURL: URL(string: "https://is2-ssl.mzstatic.com/image/thumb/Podcasts115/v4/d8/68/49/"
                                    + "d868497c-f3b5-f40d-00d7-514cbdc3ac8b/mza_12097083422146527699.jpg/100x100bb.jpg")!
    )

    public static let fixtureFukabori = ITunesShow(
        id: 81934699,
        artistName: "iwashi",
        showName: "fukabori.fm",
        feedURL: URL(string: "https://rss.art19.com/fukabori")!,
        artworkURL: URL(string: "https://is4-ssl.mzstatic.com/image/thumb/Podcasts123/v4/02/97/14/"
                            + "0297144d-fd3d-8f10-b8d1-2f6331e06f9c/mza_4554497525722024755.jpeg/600x600bb.jpg")!,
        artworkLowQualityURL: URL(string: "https://is4-ssl.mzstatic.com/image/thumb/Podcasts123/v4/02/97/14/"
                                    + "0297144d-fd3d-8f10-b8d1-2f6331e06f9c/mza_4554497525722024755.jpeg/100x100bb.jpg")!
    )

    public static let fixtureSuperLongProperties = ITunesShow(
        id: 81934259,
        artistName: "すごく長い運営者の名前 and すごく長い運営者の名前 and すごく長い運営者の名前 and すごく長い運営者の名前",
        showName: "すごく長いタイトルすごく長いタイトルすごく長いタイトルすごく長いタイトルすごく長いタイトルすごく長いタイトル",
        feedURL: URL(string: "https://rss.art19.com/superlong")!,
        artworkURL: URL(string: "https://pbs.twimg.com/profile_images/1456394232143695872/hifjifgW_400x400.jpg")!,
        artworkLowQualityURL: URL(string: "https://pbs.twimg.com/profile_images/1456394232143695872/hifjifgW_400x400.jpg")!
    )
}

#endif
