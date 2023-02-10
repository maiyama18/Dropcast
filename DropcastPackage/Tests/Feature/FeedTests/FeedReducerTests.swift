import ComposableArchitecture
import DatabaseClient
import Entity
import TestHelper
import XCTest

@testable import FeedFeature

@MainActor
final class FeedReducerTests: XCTestCase {
    func test_feed_is_initialized_with_episodes_of_followed_shows() async {
        let store = TestStore(
            initialState: FeedReducer.State(),
            reducer: FeedReducer()
        ) {
            $0.databaseClient = .live(persistentProvider: InMemoryPersistentProvider())
            do {
                try $0.databaseClient.followShow(.fixtureRebuild)
            } catch {
                XCTFail()
            }
        }

        let task = await store.send(.task)
        await store.receive(.episodesResponse(IdentifiedArrayOf(uniqueElements: [.fixtureRebuild352, .fixtureRebuild351, .fixtureRebuild350]))) {
            $0.episodes = [.fixtureRebuild352, .fixtureRebuild351, .fixtureRebuild350]
        }

        await task.cancel()
    }

    func test_episodes_of_followed_shows_are_added_to_feed() async throws {
        let databaseClient: DatabaseClient = .live(persistentProvider: InMemoryPersistentProvider())
        let store = TestStore(
            initialState: FeedReducer.State(),
            reducer: FeedReducer()
        ) {
            $0.databaseClient = databaseClient
            do {
                try $0.databaseClient.followShow(.fixtureRebuild)
            } catch {
                XCTFail()
            }
        }

        let task = await store.send(.task)
        await store.receive(.episodesResponse(IdentifiedArrayOf(uniqueElements: [.fixtureRebuild352, .fixtureRebuild351, .fixtureRebuild350]))) {
            $0.episodes = [.fixtureRebuild352, .fixtureRebuild351, .fixtureRebuild350]
        }

        try databaseClient.followShow(.fixtureSwiftBySundell)
        await store.receive(
            .episodesResponse(IdentifiedArrayOf(uniqueElements: [
                .fixtureRebuild352,
                .fixtureSwiftBySundell123,
                .fixtureRebuild351,
                .fixtureRebuild350,
                .fixtureSwiftBySundell122,
                .fixtureSwiftBySundell121,
            ]))
        ) {
            $0.episodes = [
                .fixtureRebuild352,
                .fixtureSwiftBySundell123,
                .fixtureRebuild351,
                .fixtureRebuild350,
                .fixtureSwiftBySundell122,
                .fixtureSwiftBySundell121,
            ]
        }

        await task.cancel()
    }

    func test_episodes_of_unfollowed_shows_are_removed_to_feed() async throws {
        let databaseClient: DatabaseClient = .live(persistentProvider: InMemoryPersistentProvider())
        let store = TestStore(
            initialState: FeedReducer.State(),
            reducer: FeedReducer()
        ) {
            $0.databaseClient = databaseClient
            do {
                try $0.databaseClient.followShow(.fixtureRebuild)
                try databaseClient.followShow(.fixtureSwiftBySundell)
            } catch {
                XCTFail()
            }
        }

        let task = await store.send(.task)
        await store.receive(
            .episodesResponse(IdentifiedArrayOf(uniqueElements: [
                .fixtureRebuild352,
                .fixtureSwiftBySundell123,
                .fixtureRebuild351,
                .fixtureRebuild350,
                .fixtureSwiftBySundell122,
                .fixtureSwiftBySundell121,
            ]))
        ) {
            $0.episodes = [
                .fixtureRebuild352,
                .fixtureSwiftBySundell123,
                .fixtureRebuild351,
                .fixtureRebuild350,
                .fixtureSwiftBySundell122,
                .fixtureSwiftBySundell121,
            ]
        }

        try databaseClient.unfollowShow(Show.fixtureSwiftBySundell.feedURL)
        await store.receive(.episodesResponse(IdentifiedArrayOf(uniqueElements: [.fixtureRebuild352, .fixtureRebuild351, .fixtureRebuild350]))) {
            $0.episodes = [.fixtureRebuild352, .fixtureRebuild351, .fixtureRebuild350]
        }

        await task.cancel()
    }
}
