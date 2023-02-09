import ComposableArchitecture
import DatabaseClient
import Entity
import Error
import TestHelper
import XCTest

@testable import ShowsFeature

@MainActor
final class ShowListReducerTests: XCTestCase {
    func test_list_is_initialized_with_followed_shows() async {
        let store = TestStore(
            initialState: ShowListReducer.State(),
            reducer: ShowListReducer()._printChanges()
        ) {
            $0.databaseClient = .live(persistentProvider: InMemoryPersistentProvider())
            do {
                try $0.databaseClient.followShow(.fixtureRebuild)
            } catch {
                XCTFail()
            }
        }

        let task = await store.send(.task)
        await store.receive(.showsResponse(IdentifiedArrayOf(uniqueElements: [.fixtureRebuild]))) {
            $0.shows = [.fixtureRebuild]
        }

        await task.cancel()
    }

    func test_followed_show_is_added_to_list() async throws {
        let databaseClient: DatabaseClient = .live(persistentProvider: InMemoryPersistentProvider())
        let store = TestStore(
            initialState: ShowListReducer.State(),
            reducer: ShowListReducer()._printChanges()
        ) {
            $0.databaseClient = databaseClient
            do {
                try $0.databaseClient.followShow(.fixtureRebuild)
            } catch {
                XCTFail()
            }
        }

        let task = await store.send(.task)
        await store.receive(.showsResponse(IdentifiedArrayOf(uniqueElements: [.fixtureRebuild]))) {
            $0.shows = [.fixtureRebuild]
        }

        try databaseClient.followShow(.fixtureSwiftBySundell)

        await store.receive(
            .showsResponse(
                IdentifiedArrayOf(uniqueElements: [.fixtureRebuild, .fixtureSwiftBySundell])
            )
        ) {
            $0.shows = [.fixtureRebuild, .fixtureSwiftBySundell]
        }

        await task.cancel()
    }

    func test_unfollowed_show_is_removed_to_list() async throws {
        let databaseClient: DatabaseClient = .live(persistentProvider: InMemoryPersistentProvider())
        let store = TestStore(
            initialState: ShowListReducer.State(),
            reducer: ShowListReducer()._printChanges()
        ) {
            $0.databaseClient = databaseClient
            do {
                try $0.databaseClient.followShow(.fixtureRebuild)
            } catch {
                XCTFail()
            }
        }

        let task = await store.send(.task)
        await store.receive(.showsResponse(IdentifiedArrayOf(uniqueElements: [.fixtureRebuild]))) {
            $0.shows = [.fixtureRebuild]
        }

        await store.send(.showSwipeToDeleted(feedURL: Show.fixtureRebuild.feedURL))
        await store.receive(.showsResponse(IdentifiedArrayOf(uniqueElements: []))) {
            $0.shows = []
        }

        await task.cancel()
    }

    func test_tapping_show_makes_transition() async {
        let store = TestStore(
            initialState: ShowListReducer.State(),
            reducer: ShowListReducer()
        ) {
            $0.databaseClient = .live(persistentProvider: InMemoryPersistentProvider())
            do {
                try $0.databaseClient.followShow(.fixtureRebuild)
            } catch {
                XCTFail()
            }
        }

        let task = await store.send(.task)
        await store.receive(.showsResponse(IdentifiedArrayOf(uniqueElements: [.fixtureRebuild]))) {
            $0.shows = [.fixtureRebuild]
        }

        await store.send(.showDetailSelected(feedURL: Show.fixtureRebuild.feedURL)) {
            $0.selectedShowState = Identified(
                .init(
                    feedURL: Show.fixtureRebuild.feedURL,
                    imageURL: Show.fixtureRebuild.imageURL,
                    title: Show.fixtureRebuild.title,
                    episodes: Show.fixtureRebuild.episodes,
                    author: Show.fixtureRebuild.author,
                    description: Show.fixtureRebuild.description,
                    linkURL: Show.fixtureRebuild.linkURL
                ),
                id: Show.fixtureRebuild.feedURL
            )
        }

        await task.cancel()
    }
}
