import DatabaseClient
import Entity
import XCTest

@testable import DatabaseClientLive

final class DatabaseClientLiveTests: XCTestCase {
    private var client: DatabaseClient!

    override func setUp() {
        client = .live(persistentProvider: InMemoryPersistentProvider())
    }

    func test_followed_shows_are_included_in_fetch_results() throws {
        XCTAssertEqual(try client.fetchFollowingShows(), [])

        try client.followShow(.fixtureRebuild)

        XCTAssertEqual(try client.fetchFollowingShows(), [.fixtureRebuild])

        try client.followShow(.fixtureSwiftBySundell)

        XCTAssertEqual(try client.fetchFollowingShows(), [.fixtureRebuild, .fixtureSwiftBySundell])
    }

    func test_fetch_results_are_sorted_by_title() throws {
        try client.followShow(.fixtureSwiftBySundell)
        try client.followShow(.fixtureプログラム雑談)
        try client.followShow(.fixtureRebuild)

        XCTAssertEqual(
            try client.fetchFollowingShows(),
            [
                .fixtureRebuild,
                .fixtureSwiftBySundell,
                .fixtureプログラム雑談,
            ]
        )
    }

    // FIXME: test_following_already_followed_show_does_not_create_duplicated_entity
}
