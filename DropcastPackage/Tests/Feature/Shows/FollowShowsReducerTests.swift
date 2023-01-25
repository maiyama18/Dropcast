import ComposableArchitecture
import TestHelper
import XCTest

@testable import ShowsFeature

@MainActor
final class FollowShowsReducerTests: XCTestCase {
    func test_queryChangeDebounced_searchSuccess_queryChangedToEmpty_showsCleared() async {
        let store = TestStore(
            initialState: FollowShowsReducer.State(),
            reducer: FollowShowsReducer()
        ) {
            $0.iTunesClient.searchShows = { query in
                guard query == "stack" else {
                    XCTFail()
                    throw TestError.somethingWentWrong
                }
                return [.fixtureStacktrace, .fixtureStackOverflow]
            }
        }

        await store.send(.queryChanged(query: "stack")) {
            $0.query = "stack"
        }

        await store.send(.queryChangeDebounced)
        await store.receive(.searchResponse(.success([.fixtureStacktrace, .fixtureStackOverflow]))) {
            $0.shows = .present(shows: [.fixtureStacktrace, .fixtureStackOverflow])
        }

        await store.send(.queryChanged(query: "")) {
            $0.query = ""
            $0.shows = .present(shows: [])
        }
    }

    func test_queryChangeDebounced_searchEmpty() async {
        let store = TestStore(
            initialState: FollowShowsReducer.State(),
            reducer: FollowShowsReducer()
        ) {
            $0.iTunesClient.searchShows = { query in
                guard query == "stack" else {
                    XCTFail()
                    throw TestError.somethingWentWrong
                }
                return []
            }
        }

        await store.send(.queryChanged(query: "stack")) {
            $0.query = "stack"
        }

        await store.send(.queryChangeDebounced)
        await store.receive(.searchResponse(.success([]))) {
            $0.shows = .empty
        }
    }

    func test_queryChangeDebounced_searchFailure() async {
        let errorMessage: LockIsolated<String?> = .init(nil)
        let store = TestStore(
            initialState: FollowShowsReducer.State(),
            reducer: FollowShowsReducer()
        ) {
            $0.iTunesClient.searchShows = { _ in
                throw TestError.somethingWentWrong
            }
            $0.messageClient.presentError = { message in
                errorMessage.withValue { $0 = message }
            }
        }

        await store.send(.queryChanged(query: "stack")) {
            $0.query = "stack"
        }
        await store.send(.queryChangeDebounced)
        await store.receive(.searchResponse(.failure(TestError.somethingWentWrong)))

        XCTAssertEqual(errorMessage.value, "Something went wrong")
    }

    func test_queryChangedToEmpty_whileSearchRequestInFlight() async {
        let clock = TestClock()

        let store = TestStore(
            initialState: FollowShowsReducer.State(),
            reducer: FollowShowsReducer()
        ) {
            $0.iTunesClient.searchShows = { query in
                guard query == "stack" else {
                    XCTFail()
                    throw TestError.somethingWentWrong
                }
                try await clock.sleep(for: .seconds(1))
                return [.fixtureStacktrace, .fixtureStackOverflow]
            }
        }

        await store.send(.queryChanged(query: "stack")) {
            $0.query = "stack"
        }
        await store.send(.queryChangeDebounced)
        await store.send(.queryChanged(query: "")) {
            $0.query = ""
            $0.shows = .present(shows: [])
        }
        await clock.advance(by: .seconds(1))
    }
}
