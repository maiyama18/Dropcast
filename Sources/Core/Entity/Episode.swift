import Formatter
import Foundation

public struct Episode: Sendable, Identifiable, Equatable {
    public var id: String
    public var title: String
    public var subtitle: String?
    public var description: String?
    public var duration: TimeInterval
    public var soundURL: URL
    public var publishedAt: Date

    public var showFeedURL: URL
    public var showTitle: String
    public var showImageURL: URL

    public init(
        id: String,
        title: String,
        subtitle: String?,
        description: String?,
        duration: TimeInterval,
        soundURL: URL,
        publishedAt: Date,
        showFeedURL: URL,
        showTitle: String,
        showImageURL: URL
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.duration = duration
        self.soundURL = soundURL
        self.publishedAt = publishedAt

        self.showFeedURL = showFeedURL
        self.showTitle = showTitle
        self.showImageURL = showImageURL
    }
}

// swiftlint:disable line_length

#if DEBUG
extension Episode {
    public static let fixtureRebuild352 = Episode(
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
        duration: 7907,
        soundURL: URL(string: "https://cache.rebuild.fm/podcast-ep352.mp3")!,
        publishedAt: rssDateFormatter.date(from: "Tue, 03 Jan 2023 20:00:00 -0800")!,
        showFeedURL: URL(string: "https://feeds.rebuild.fm/rebuildfm")!,
        showTitle: "Rebuild",
        showImageURL: URL(string: "https://cdn.rebuild.fm/images/icon1400.jpg")!
    )
    public static let fixtureRebuild351 = Episode(
        id: "https://rebuild.fm/351/",
        title: "351: Time For Change (hak)",
        subtitle: "Hakuro Matsuda さんをゲストに迎えて、CES, VR, Apple TV, Twitter などについて話しました。",
        description: """
        <p>Hakuro Matsuda さんをゲストに迎えて、CES, VR, Apple TV, Twitter などについて話しました。</p>
        <h3>Show Notes</h3><ul>
        <li><a href="https://rebuild.fm/portal/">Rebuild Supporter</a></li>
        <li><a href="https://gumroad.com/">Gumroad</a></li>
        </ul>
        """,
        duration: 9015,
        soundURL: URL(string: "https://cache.rebuild.fm/podcast-ep351.mp3")!,
        publishedAt: rssDateFormatter.date(from: "Tue, 06 Dec 2022 23:00:00 -0800")!,
        showFeedURL: URL(string: "https://feeds.rebuild.fm/rebuildfm")!,
        showTitle: "Rebuild",
        showImageURL: URL(string: "https://cdn.rebuild.fm/images/icon1400.jpg")!
    )
    public static let fixtureRebuild350 = Episode(
        id: "https://rebuild.fm/350/",
        title: "350: Mister O-1 (N, naan)",
        subtitle: "Naoki Hiroshima さん、Kazuho Okui さんをゲストに迎えて、近況、Twitter, USB-C, ChatGPT などについて話しました。",
        description: """
        <p>Naoki Hiroshima さん、Kazuho Okui さんをゲストに迎えて、近況、Twitter, USB-C, ChatGPT などについて話しました。</p>
        <h3>Show Notes</h3><ul>
        <li><a href="https://www.theverge.com/2022/12/15/23512113/twitter-blocking-mastodon-links-elon-musk-elonjet">Twitter is blocking links to Mastodon</a></li>
        </ul>
        """,
        duration: 7500,
        soundURL: URL(string: "https://cache.rebuild.fm/podcast-ep350.mp3")!,
        publishedAt: rssDateFormatter.date(from: "Mon, 21 Nov 2022 22:00:00 -0800")!,
        showFeedURL: URL(string: "https://feeds.rebuild.fm/rebuildfm")!,
        showTitle: "Rebuild",
        showImageURL: URL(string: "https://cdn.rebuild.fm/images/icon1400.jpg")!
    )

    public static let fixtureSwiftBySundell123 = Episode(
        id: "https://www.swiftbysundell.com/podcast/123",
        title: "123: “The evolution of Swift”, with special guest Nick Lockwood",
        subtitle: "On this final episode of 2022, Nick Lockwood returns to the show to discuss the overall evolution of Swift and its ecosystem of tools and libraries. How has Swift changed since its original introduction in 2014, how does it compare to other modern programming languages, and how might the language continue to evolve in 2023 and beyond?",
        description: "<p>On this final episode of 2022, Nick Lockwood returns to the show to discuss the overall evolution of Swift and its ecosystem of tools and libraries. How has Swift changed since its original introduction in 2014, how does it compare to other modern programming languages, and how might the language continue to evolve in 2023 and beyond?</p>",
        duration: 3807,
        soundURL: URL(string: "https://traffic.libsyn.com/swiftbysundell/SwiftBySundell123.mp3")!,
        publishedAt: rssDateFormatter.date(from: "Mon, 19 Dec 2022 16:05:00 +0100")!,
        showFeedURL: URL(string: "https://www.swiftbysundell.com/podcast/feed.rss")!,
        showTitle: "Swift by Sundell",
        showImageURL: URL(string: "https://www.swiftbysundell.com/images/podcastArtwork.png")!
    )
    public static let fixtureSwiftBySundell122 = Episode(
        id: "https://www.swiftbysundell.com/podcast/122",
        title: "122: “Swift concurrency in practice”, with special guest Ben Scheirman",
        subtitle: "Ben Scheirman returns to the show to discuss how Swift’s built-in concurrency features, such as async/await and tasks, can be used in practice when building apps for Apple’s platforms.",
        description: "<p>Ben Scheirman returns to the show to discuss how Swift’s built-in concurrency features, such as async/await and tasks, can be used in practice when building apps for Apple’s platforms.</p>",
        duration: 3862,
        soundURL: URL(string: "https://traffic.libsyn.com/swiftbysundell/SwiftBySundell122.mp3")!,
        publishedAt: rssDateFormatter.date(from: "Fri, 18 Nov 2022 20:30:00 +0100")!,
        showFeedURL: URL(string: "https://www.swiftbysundell.com/podcast/feed.rss")!,
        showTitle: "Swift by Sundell",
        showImageURL: URL(string: "https://www.swiftbysundell.com/images/podcastArtwork.png")!
    )
    public static let fixtureSwiftBySundell121 = Episode(
        id: "https://www.swiftbysundell.com/podcast/121",
        title: "121: “Responsive and smooth UIs”, with special guest Adam Bell",
        subtitle: "Adam Bell returns to the podcast to discuss different techniques and approaches for optimizing UI code, and how to utilize tools like animations in order to build iOS apps that feel fast and responsive.",
        description: "<p>Adam Bell returns to the podcast to discuss different techniques and approaches for optimizing UI code, and how to utilize tools like animations in order to build iOS apps that feel fast and responsive.</p>",
        duration: 4212,
        soundURL: URL(string: "https://traffic.libsyn.com/swiftbysundell/SwiftBySundell121.mp3")!,
        publishedAt: rssDateFormatter.date(from: "Mon, 31 Oct 2022 18:45:00 +0100")!,
        showFeedURL: URL(string: "https://www.swiftbysundell.com/podcast/feed.rss")!,
        showTitle: "Swift by Sundell",
        showImageURL: URL(string: "https://www.swiftbysundell.com/images/podcastArtwork.png")!
    )

    public static let fixtureプログラム雑談225 = Episode(
        id: "955dc198-f1c2-4d02-8711-1ad458c67268",
        title: "225回 週、月、年の振り返りとか抱負とか",
        subtitle: "<p>年末の振り返りとか翌年の抱負とかって結構いいよな、という雑談。</p>",
        description: "<p>年末の振り返りとか翌年の抱負とかって結構いいよな、という雑談。</p>",
        duration: 2928,
        soundURL: URL(string: "https://anchor.fm/s/68ce140/podcast/play/63000195/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fproduction%2F2023-0-3%2F305764900-44100-1-cb235f2dd11b.m4a")!,
        publishedAt: rssDateFormatter.date(from: "Wed, 04 Jan 2023 11:00:20 GMT")!,
        showFeedURL: URL(string: "https://anchor.fm/s/68ce140/podcast/rss")!,
        showTitle: "プログラム雑談",
        showImageURL: URL(string: "https://d3t3ozftmdmh3i.cloudfront.net/production/podcast_uploaded/998960/998960-1535212397504-93ed2911e3e38.jpg")!
    )
    public static let fixtureプログラム雑談224 = Episode(
        id: "f64a0aaf-0baa-4257-b78e-b0b01e53cf60",
        title: "224回 プログラムエッセイとか昔のワインバーグの本読んでるとかの雑談",
        subtitle: """
        <p>プログラミングの心理学を読んでて思ったことやプログラミング関連エッセイについての雑談。</p>
        <p><a href="https://karino2.github.io/RandomThoughts/%E3%80%90%E6%9B%B8%E7%B1%8D%E3%80%91%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%9F%E3%83%B3%E3%82%B0%E3%81%AE%E5%BF%83%E7%90%86%E5%AD%A6">RandomThoughts: プログラミングの心理学</a></p>
        """,
        description: """
        <p>プログラミングの心理学を読んでて思ったことやプログラミング関連エッセイについての雑談。</p>
        <p><a href="https://karino2.github.io/RandomThoughts/%E3%80%90%E6%9B%B8%E7%B1%8D%E3%80%91%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%9F%E3%83%B3%E3%82%B0%E3%81%AE%E5%BF%83%E7%90%86%E5%AD%A6">RandomThoughts: プログラミングの心理学</a></p>
        """,
        duration: 2273,
        soundURL: URL(string: "https://anchor.fm/s/68ce140/podcast/play/62764464/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fproduction%2F2022-11-28%2F305017337-22050-1-aee208b57ad35.m4a")!,
        publishedAt: rssDateFormatter.date(from: "Wed, 28 Dec 2022 11:00:54 GMT")!,
        showFeedURL: URL(string: "https://anchor.fm/s/68ce140/podcast/rss")!,
        showTitle: "プログラム雑談",
        showImageURL: URL(string: "https://d3t3ozftmdmh3i.cloudfront.net/production/podcast_uploaded/998960/998960-1535212397504-93ed2911e3e38.jpg")!
    )
    public static let fixtureプログラム雑談223 = Episode(
        id: "7cb976f8-660a-414e-bfd1-aefe3ef82f34",
        title: "223回 奄美大島にワーケーションに来たという雑談",
        subtitle: "<p>奄美に来たぜひゃっほい！って回。</p>",
        description: "<p>奄美に来たぜひゃっほい！って回。</p>",
        duration: 1859,
        soundURL: URL(string: "https://anchor.fm/s/68ce140/podcast/play/62498064/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fproduction%2F2022-11-21%2F304198620-44100-1-df2e9b1f1f99.m4a")!,
        publishedAt: rssDateFormatter.date(from: "Wed, 21 Dec 2022 11:01:00 GMT")!,
        showFeedURL: URL(string: "https://anchor.fm/s/68ce140/podcast/rss")!,
        showTitle: "プログラム雑談",
        showImageURL: URL(string: "https://d3t3ozftmdmh3i.cloudfront.net/production/podcast_uploaded/998960/998960-1535212397504-93ed2911e3e38.jpg")!
    )
}
#endif

// swiftlint:enable line_length
