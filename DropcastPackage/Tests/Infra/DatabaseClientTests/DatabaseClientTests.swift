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

    func test_followed_shows_are_received_from_channel_and_ordered_by_title() async throws {
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

    func test_following_already_followed_show_does_not_have_any_effect() async throws {
        let followedShowsSequence = client.followedShowsStream()

        try await XCTAssertReceive(from: followedShowsSequence, [])

        try client.followShow(.fixtureRebuild)
        try await XCTAssertReceive(from: followedShowsSequence, [.fixtureRebuild])

        try client.followShow(.fixtureRebuild)

        try await XCTAssertNoReceive(from: followedShowsSequence)
    }
}
