import CustomDump
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
    
    func test_fetch_followed_shows() async throws {
        XCTAssertNoDifference(client.fetchFollowedShows(), .success([]))
        
        try client.followShow(.fixtureSwiftBySundell).get()
        
        XCTAssertNoDifference(client.fetchFollowedShows(), .success([.fixtureSwiftBySundell]))
        
        try client.followShow(.fixtureRebuild).get()
        try client.followShow(.fixtureプログラム雑談).get()
        
        XCTAssertNoDifference(
            client.fetchFollowedShows(),
            .success([.fixtureRebuild, .fixtureSwiftBySundell, .fixtureプログラム雑談])
        )
    }

    func test_followed_shows_are_received_from_stream_and_ordered_by_title() async throws {
        let followedShowsSequence = client.followedShowsStream()

        try await XCTAssertReceive(from: followedShowsSequence, [])

        Task { [client = self.client!] in
            try client.followShow(.fixtureSwiftBySundell).get()
        }
        try await XCTAssertReceive(from: followedShowsSequence, [.fixtureSwiftBySundell])

        Task { [client = self.client!] in
            try client.followShow(.fixtureRebuild).get()
        }
        try await XCTAssertReceive(from: followedShowsSequence, [.fixtureRebuild, .fixtureSwiftBySundell])

        Task { [client = self.client!] in
            try client.followShow(.fixtureプログラム雑談).get()
        }
        try await XCTAssertReceive(from: followedShowsSequence, [.fixtureRebuild, .fixtureSwiftBySundell, .fixtureプログラム雑談])

        try await XCTAssertNoReceive(from: followedShowsSequence)
    }

    func test_following_already_followed_show_has_no_effect() async throws {
        let followedShowsSequence = client.followedShowsStream()

        try await XCTAssertReceive(from: followedShowsSequence, [])

        Task { [client = self.client!] in
            try client.followShow(.fixtureRebuild).get()
        }
        try await XCTAssertReceive(from: followedShowsSequence, [.fixtureRebuild])

        Task { [client = self.client!] in
            try client.followShow(.fixtureRebuild).get()
        }

        try await XCTAssertNoReceive(from: followedShowsSequence)
    }

    func test_unfollow_show() async throws {
        try client.followShow(.fixtureSwiftBySundell).get()
        try client.followShow(.fixtureRebuild).get()
        try client.followShow(.fixtureプログラム雑談).get()

        let followedShowsSequence = client.followedShowsStream()

        try await XCTAssertReceive(from: followedShowsSequence, [.fixtureRebuild, .fixtureSwiftBySundell, .fixtureプログラム雑談])

        Task { [client = self.client!] in
            try client.unfollowShow(Show.fixtureSwiftBySundell.feedURL).get()
        }
        try await XCTAssertReceive(from: followedShowsSequence, [.fixtureRebuild, .fixtureプログラム雑談])

        Task { [client = self.client!] in
            try client.unfollowShow(Show.fixtureプログラム雑談.feedURL).get()
        }
        try await XCTAssertReceive(from: followedShowsSequence, [.fixtureRebuild])

        Task { [client = self.client!] in
            try client.unfollowShow(Show.fixtureRebuild.feedURL).get()
        }
        try await XCTAssertReceive(from: followedShowsSequence, [])
    }

    func test_unfollowing_not_following_show_has_no_effect() async throws {
        try client.followShow(.fixtureSwiftBySundell).get()

        let followedShowsSequence = client.followedShowsStream()

        try await XCTAssertReceive(from: followedShowsSequence, [.fixtureSwiftBySundell])

        Task { [client = self.client!] in
            try client.unfollowShow(Show.fixtureRebuild.feedURL).get()
        }
        try await XCTAssertNoReceive(from: followedShowsSequence)
    }

    func test_episodes_of_followed_shows_are_received_from_stream_and_ordered_by_published_at() async throws {
        let followedEpisodesSequence = client.followedEpisodesStream()

        try await XCTAssertReceive(from: followedEpisodesSequence, [])

        Task { [client = self.client!] in
            try client.followShow(.fixtureSwiftBySundell).get()
        }
        try await XCTAssertReceive(
            from: followedEpisodesSequence,
            [
                .fixtureSwiftBySundell123,
                .fixtureSwiftBySundell122,
                .fixtureSwiftBySundell121,
            ]
        )

        Task { [client = self.client!] in
            try client.followShow(.fixtureRebuild).get()
        }
        try await XCTAssertReceive(
            from: followedEpisodesSequence,
            [
                .fixtureRebuild352,
                .fixtureSwiftBySundell123,
                .fixtureRebuild351,
                .fixtureRebuild350,
                .fixtureSwiftBySundell122,
                .fixtureSwiftBySundell121,
            ]
        )

        Task { [client = self.client!] in
            try client.followShow(.fixtureプログラム雑談).get()
        }
        try await XCTAssertReceive(
            from: followedEpisodesSequence,
            [
                .fixtureプログラム雑談225,
                .fixtureRebuild352,
                .fixtureプログラム雑談224,
                .fixtureプログラム雑談223,
                .fixtureSwiftBySundell123,
                .fixtureRebuild351,
                .fixtureRebuild350,
                .fixtureSwiftBySundell122,
                .fixtureSwiftBySundell121,
            ]
        )
    }

    func test_episodes_of_unfollowed_shows_are_removed_from_stream() async throws {
        try client.followShow(.fixtureSwiftBySundell).get()
        try client.followShow(.fixtureRebuild).get()
        try client.followShow(.fixtureプログラム雑談).get()

        let followedEpisodesSequence = client.followedEpisodesStream()
        try await XCTAssertReceive(
            from: followedEpisodesSequence,
            [
                .fixtureプログラム雑談225,
                .fixtureRebuild352,
                .fixtureプログラム雑談224,
                .fixtureプログラム雑談223,
                .fixtureSwiftBySundell123,
                .fixtureRebuild351,
                .fixtureRebuild350,
                .fixtureSwiftBySundell122,
                .fixtureSwiftBySundell121,
            ]
        )

        Task { [client = self.client!] in
            try client.unfollowShow(Show.fixtureSwiftBySundell.feedURL).get()
        }
        try await XCTAssertReceive(
            from: followedEpisodesSequence,
            [
                .fixtureプログラム雑談225,
                .fixtureRebuild352,
                .fixtureプログラム雑談224,
                .fixtureプログラム雑談223,
                .fixtureRebuild351,
                .fixtureRebuild350,
            ]
        )
    }
}
