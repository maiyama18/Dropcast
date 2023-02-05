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
            $0.shows = [.init(show: .fixtureRebuild)]
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
            $0.shows = [.init(show: .fixtureRebuild)]
        }

        try databaseClient.followShow(.fixtureSwiftBySundell)

        await store.receive(
            .showsResponse(
                IdentifiedArrayOf(uniqueElements: [.fixtureRebuild, .fixtureSwiftBySundell])
            )
        ) {
            $0.shows = [.init(show: .fixtureRebuild), .init(show: .fixtureSwiftBySundell)]
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
            $0.shows = [.init(show: .fixtureRebuild)]
        }

        await store.send(.showSwipeToDeleted(feedURL: Show.fixtureRebuild.feedURL))
        await store.receive(.showsResponse(IdentifiedArrayOf(uniqueElements: []))) {
            $0.shows = []
        }

        await task.cancel()
    }
}
