import TestHelper
import XCTest

@testable import ITunesClient

final class ITunesClientTests: XCTestCase {
    private var client: ITunesClient!

    override func setUp() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        let urlSession = URLSession(configuration: config)

        client = .live(urlSession: urlSession)
    }

    func testSearch() async throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "Rebuild", withExtension: "json"))
        let data = try Data(contentsOf: url)
        URLProtocolStub.setResponses(
            [
                URL(string: "https://itunes.apple.com/search?media=podcast&term=rebuild")!: .init(statusCode: 200, result: .success(data))
            ]
        )

        let shows = try await client.searchShows("rebuild").get()
        XCTAssertEqual(shows.count, 50)
        for show in shows {
            XCTAssertEqual(show.feedURL.scheme, "https")
        }

        let rebuild = shows[0]
        XCTAssertEqual(rebuild.id, 603013428)
        XCTAssertEqual(rebuild.artistName, "Tatsuhiko Miyagawa")
        XCTAssertEqual(rebuild.showName, "Rebuild")
        XCTAssertEqual(
            rebuild.feedURL,
            URL(string: "https://feeds.rebuild.fm/rebuildfm")
        )
        XCTAssertEqual(
            rebuild.artworkURL,
            URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Podcasts125/v4/d6/20/fe/d620fea4-8f14-8402-1041-0388a31720e6/mza_1949949944137970976.jpg/600x600bb.jpg")
        )
    }

    func testSearch_emptyResult() async throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "Empty", withExtension: "json"))
        let data = try Data(contentsOf: url)
        URLProtocolStub.setResponses(
            [
                URL(string: "https://itunes.apple.com/search?media=podcast&term=empty")!: .init(statusCode: 200, result: .success(data))
            ]
        )

        let shows = try await client.searchShows("empty").get()
        XCTAssertEqual(shows.count, 0)
    }

    func testSearch_queryNotASCII_properlyEncoded() async throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "Bilingual", withExtension: "json"))
        let data = try Data(contentsOf: url)
        URLProtocolStub.setResponses(
            [
                URL(string: "https://itunes.apple.com/search?media=podcast&term=%E3%83%90%E3%82%A4%E3%83%AA%E3%83%B3%E3%82%AC%E3%83%AB")!:
                        .init(statusCode: 200, result: .success(data)),
            ]
        )

        let shows = try await client.searchShows("バイリンガル").get()
        XCTAssertEqual(shows.count, 22)
    }
}
