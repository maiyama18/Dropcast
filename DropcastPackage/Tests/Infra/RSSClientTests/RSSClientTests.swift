import TestHelper
import XCTest

@testable import RSSClient

// swiftlint:disable line_length

final class RSSClientTests: XCTestCase {
    private var client: RSSClient!

    override func setUp() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        let urlSession = URLSession(configuration: config)

        client = .live(urlSession: urlSession)
    }

    func testRebuild() async throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "Rebuild", withExtension: "xml"))
        let data = try Data(contentsOf: url)

        let feedURL = URL(string: "https://feeds.rebuild.fm/rebuildfm")!
        URLProtocolStub.setResponses(
            [
                feedURL: .init(statusCode: 200, result: .success(data))
            ]
        )

        let show = try await client.fetch(feedURL)
        XCTAssertEqual(show.title, "Rebuild")
        XCTAssertEqual(show.description, "ウェブ開発、プログラミング、モバイル、ガジェットなどにフォーカスしたテクノロジー系ポッドキャストです。 #rebuildfm")
        XCTAssertEqual(show.author, "Tatsuhiko Miyagawa")
        XCTAssertEqual(show.imageURL, URL(string: "https://cdn.rebuild.fm/images/icon1400.jpg")!)
        XCTAssertEqual(show.linkURL, URL(string: "https://rebuild.fm")!)
        XCTAssertEqual(show.episodes.count, 477)

        let latestEpisode = try XCTUnwrap(show.episodes.first)
        XCTAssertEqual(latestEpisode.id, "https://rebuild.fm/352/")
        XCTAssertEqual(latestEpisode.title, "352: There's a Fifth Way (naoya)")
        XCTAssertEqual(latestEpisode.subtitle, "Naoya Ito さんをゲストに迎えて、MacBook Pro, キーボード、競技プログラミング、レイオフ、ゲームなどについて話しました。")
        XCTAssertEqual(latestEpisode.description?.starts(with: "<p>Naoya Ito さんをゲストに迎えて、MacBook Pro, キーボード、競技プログラミング、レイオフ、ゲームなどについて話しました。</p>"), true)
        XCTAssertEqual(latestEpisode.duration, 131 * 60 + 47)
        XCTAssertEqual(latestEpisode.soundURL, URL(string: "https://cache.rebuild.fm/podcast-ep352.mp3")!)
    }

    func testSwiftBySundell() async throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "SwiftBySundell", withExtension: "xml"))
        let data = try Data(contentsOf: url)

        let feedURL = URL(string: "https://swiftbysundell.com/podcast/feed.rss")!
        URLProtocolStub.setResponses(
            [
                feedURL: .init(statusCode: 200, result: .success(data))
            ]
        )

        let show = try await client.fetch(feedURL)
        XCTAssertEqual(show.title, "Swift by Sundell")
        XCTAssertEqual(show.description, "In-depth conversations about Swift and software development in general, hosted by John Sundell.")
        XCTAssertEqual(show.author, "John Sundell")
        XCTAssertEqual(show.imageURL, URL(string: "https://www.swiftbysundell.com/images/podcastArtwork.png")!)
        XCTAssertEqual(show.linkURL, URL(string: "https://www.swiftbysundell.com/podcast")!)
        XCTAssertEqual(show.episodes.count, 123)

        let latestEpisode = try XCTUnwrap(show.episodes.first)
        XCTAssertEqual(latestEpisode.id, "https://www.swiftbysundell.com/podcast/123")
        XCTAssertEqual(latestEpisode.title, "123: “The evolution of Swift”, with special guest Nick Lockwood")
        XCTAssertEqual(latestEpisode.subtitle, "On this final episode of 2022, Nick Lockwood returns to the show to discuss the overall evolution of Swift and its ecosystem of tools and libraries. How has Swift changed since its original introduction in 2014, how does it compare to other modern programming languages, and how might the language continue to evolve in 2023 and beyond?")
        XCTAssertEqual(latestEpisode.description?.starts(with: "<p>On this final episode of 2022, Nick Lockwood returns to the show to discuss the overall evolution of Swift and its ecosystem of tools and libraries. How has Swift changed since its original introduction in 2014, how does it compare to other modern programming languages, and how might the language continue to evolve in 2023 and beyond?</p>"), true)
        XCTAssertEqual(latestEpisode.duration, 63 * 60 + 27)
        XCTAssertEqual(latestEpisode.soundURL, URL(string: "https://traffic.libsyn.com/swiftbysundell/SwiftBySundell123.mp3")!)
    }

    func testプログラム雑談() async throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "ProgramChat", withExtension: "xml"))
        let data = try Data(contentsOf: url)

        let feedURL = URL(string: "https://anchor.fm/s/68ce140/podcast/rss")!
        URLProtocolStub.setResponses(
            [
                feedURL: .init(statusCode: 200, result: .success(data))
            ]
        )

        let show = try await client.fetch(feedURL)
        XCTAssertEqual(show.title, "プログラム雑談")
        XCTAssertEqual(
            show.description,
            """
            プログラム雑談はkarino2が、主にプログラムに関わる事について、雑談するpodcastです。たまにプログラムと関係ない近況とかも話します。
            お便りはこちらから。 https://odaibako.net/u/karino2012
            """
        )
        XCTAssertEqual(show.author, "Kazuma Arino")
        XCTAssertEqual(show.imageURL, URL(string: "https://d3t3ozftmdmh3i.cloudfront.net/production/podcast_uploaded/998960/998960-1535212397504-93ed2911e3e38.jpg")!)
        XCTAssertEqual(show.linkURL, URL(string: "https://anchor.fm/karino2")!)
        XCTAssertEqual(show.episodes.count, 226)

        let latestEpisode = try XCTUnwrap(show.episodes.first)
        XCTAssertEqual(latestEpisode.id, "b8c3341d-bbf1-4184-8977-137e4ee45526")
        XCTAssertEqual(latestEpisode.title, "228回 プログラマがweb上のろくでもないおっさんになってしまうメカニズムについての雑談")
        XCTAssertEqual(latestEpisode.subtitle, "<p>自分のやってる事が大したこと無いと気づく結果ろくでもないおっさんになってしまう、という新発見。</p>")
        XCTAssertEqual(latestEpisode.description?.starts(with: "<p>自分のやってる事が大したこと無いと気づく結果ろくでもないおっさんになってしまう、という新発見。</p>"), true)
        XCTAssertEqual(latestEpisode.duration, 38 * 60 + 27)
        XCTAssertEqual(latestEpisode.soundURL, URL(string: "https://anchor.fm/s/68ce140/podcast/play/63943153/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fproduction%2F2023-0-24%2F309067843-44100-1-c25d646c3be96.m4a")!)
    }

    func testStackOverflow() async throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "StackOverflow", withExtension: "xml"))
        let data = try Data(contentsOf: url)

        let feedURL = URL(string: "https://feeds.simplecast.com/XA_851k3")!
        URLProtocolStub.setResponses(
            [
                feedURL: .init(statusCode: 200, result: .success(data))
            ]
        )

        let show = try await client.fetch(feedURL)
        XCTAssertEqual(show.title, "The Stack Overflow Podcast")
        XCTAssertEqual(show.description, "For more than a dozen years, the Stack Overflow Podcast has been exploring what it means to be a developer and how the art and practice of software programming is changing our world. From Rails to React, from Java to Node.js, we host important conversations and fascinating guests that will help you understand how technology is made and where it’s headed. Hosted by Ben Popper, Cassidy Williams, and Ceora Ford, the Stack Overflow Podcast is your home for all things code.")
        XCTAssertEqual(show.author, "The Stack Overflow Podcast")
        XCTAssertEqual(show.imageURL, URL(string: "https://image.simplecastcdn.com/images/f0fdf349-149b-42f9-95d0-8ddf72185776/02a60604-9d42-4ec4-a716-8d9a2942f79c/3000x3000/stack-overflow-podcast-1080x1080.jpg?aid=rss_feed")!)
        XCTAssertEqual(show.episodes.count, 542)

        let latestEpisode = try XCTUnwrap(show.episodes.first)
        XCTAssertEqual(latestEpisode.id, "dddb9ccd-0318-4c58-aa86-ee082259ed75")
        XCTAssertEqual(latestEpisode.title, "How chaos engineering preps developers for the ultimate game day")
        XCTAssertEqual(latestEpisode.subtitle, "On this sponsored episode, our fourth in the series with Intuit, Ben and Ryan chat with Deepthi Panthula, Senior Product Manager, and Shan Anwar, Principal Software Engineer, both of Intuit about how use self-serve chaos engineering tools to control the blast radius of failures, how game day tests and drills keep their systems resilient, and how their investment in open-source software powers their program.")
        XCTAssertEqual(latestEpisode.description?.starts(with: "<p>In complex service-oriented architectures, failure can happen in individual servers and containers, then cascade through your system. Good engineering takes into account possible failures. But how do you test whether a solution actually mitigates failures without risking the ire of your customers? That’s where chaos engineering comes in, injecting failures and uncertainty into complex systems so your team can see where your architecture breaks. </p>"), true)
        XCTAssertEqual(latestEpisode.duration, 19 * 60 + 53)
        XCTAssertEqual(latestEpisode.soundURL, URL(string: "https://chrt.fm/track/G8F1AF/cdn.simplecast.com/audio/6fa1d34c-502b-4abf-bd82-483804006e0b/episodes/0211ddb5-d061-40cc-9528-36a51379586b/audio/c684cfd9-9035-4fca-8e53-d2f90e7eb73d/default_tc.mp3?aid=rss_feed&feed=XA_851k3")!)
    }
}

// swiftlint:enable line_length
