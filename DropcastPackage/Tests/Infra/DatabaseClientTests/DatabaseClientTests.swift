import DatabaseClient
import Dependencies
import Entity
import Error
import TestHelper
import XCTest

final class DatabaseClientTests: XCTestCase {
    private var persistentProvider: PersistentProvider!
    private var client: DatabaseClient!

    override func setUp() {
        persistentProvider = InMemoryPersistentProvider()
        client = .live(persistentProvider: persistentProvider)
    }

    func test_followed_shows_are_received_from_stream_and_ordered_by_title() async throws {
        let followedShowsSequence = client.followedShowsStream()

        try await XCTAssertReceive(from: followedShowsSequence, [])

        try client.followShow(.fixtureSwiftBySundell)
        try await XCTAssertReceive(from: followedShowsSequence, [.fixtureSwiftBySundell])

        try client.followShow(.fixtureRebuild)
        try await XCTAssertReceive(from: followedShowsSequence, [.fixtureRebuild, .fixtureSwiftBySundell])

        try client.followShow(.fixtureプログラム雑談)
        try await XCTAssertReceive(from: followedShowsSequence, [.fixtureRebuild, .fixtureSwiftBySundell, .fixtureプログラム雑談])

        try await XCTAssertNoReceive(from: followedShowsSequence)
    }

    func test_following_already_followed_show_has_no_effect() async throws {
        let followedShowsSequence = client.followedShowsStream()

        try await XCTAssertReceive(from: followedShowsSequence, [])

        try client.followShow(.fixtureRebuild)
        try await XCTAssertReceive(from: followedShowsSequence, [.fixtureRebuild])

        try client.followShow(.fixtureRebuild)

        try await XCTAssertNoReceive(from: followedShowsSequence)
    }

    func test_unfollow_show() async throws {
        try client.followShow(.fixtureSwiftBySundell)
        try client.followShow(.fixtureRebuild)
        try client.followShow(.fixtureプログラム雑談)

        let followedShowsSequence = client.followedShowsStream()

        try await XCTAssertReceive(from: followedShowsSequence, [.fixtureRebuild, .fixtureSwiftBySundell, .fixtureプログラム雑談])

        try client.unfollowShow(Show.fixtureSwiftBySundell.feedURL)

        try await XCTAssertReceive(from: followedShowsSequence, [.fixtureRebuild, .fixtureプログラム雑談])

        try client.unfollowShow(Show.fixtureプログラム雑談.feedURL)

        try await XCTAssertReceive(from: followedShowsSequence, [.fixtureRebuild])

        try client.unfollowShow(Show.fixtureRebuild.feedURL)

        try await XCTAssertReceive(from: followedShowsSequence, [])
    }

    func test_unfollowing_not_following_show_has_no_effect() async throws {
        try client.followShow(.fixtureSwiftBySundell)

        let followedShowsSequence = client.followedShowsStream()

        try await XCTAssertReceive(from: followedShowsSequence, [.fixtureSwiftBySundell])

        try client.unfollowShow(Show.fixtureRebuild.feedURL)

        try await XCTAssertNoReceive(from: followedShowsSequence)
    }
}
