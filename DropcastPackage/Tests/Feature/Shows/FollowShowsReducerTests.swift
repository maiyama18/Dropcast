import ComposableArchitecture
import TestHelper
import XCTest

@testable import ShowsFeature

@MainActor
final class FollowShowsReducerTests: XCTestCase {
    func test_queryChangeDebounced_searchSuccess_and_queryChangedToEmpty_promptShown() async {
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

        await store.send(.queryChangeDebounced) {
            $0.searchRequestInFlight = true
        }
        await store.receive(.searchResponse(.success([.fixtureStacktrace, .fixtureStackOverflow]))) {
            $0.searchRequestInFlight = false
            $0.showsState = .loaded(shows: [.fixtureStacktrace, .fixtureStackOverflow])
        }

        await store.send(.queryChanged(query: "")) {
            $0.query = ""
            $0.showsState = .prompt
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

        await store.send(.queryChangeDebounced) {
            $0.searchRequestInFlight = true
        }
        await store.receive(.searchResponse(.success([]))) {
            $0.searchRequestInFlight = false
            $0.showsState = .empty
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
        await store.send(.queryChangeDebounced) {
            $0.searchRequestInFlight = true
        }
        await store.receive(.searchResponse(.failure(TestError.somethingWentWrong))) {
            $0.searchRequestInFlight = false
            $0.showsState = .prompt
        }

        XCTAssertEqual(errorMessage.value, "Something went wrong")
    }

    func test_queryChangeDebounced_searchSuccess_and_searchFailure() async {
        let errorMessage: LockIsolated<String?> = .init(nil)
        let store = TestStore(
            initialState: FollowShowsReducer.State(),
            reducer: FollowShowsReducer()
        ) {
            $0.iTunesClient.searchShows = { query in
                if query == "stack" {
                    return [.fixtureStacktrace, .fixtureStackOverflow]
                } else {
                    throw TestError.somethingWentWrong
                }
            }
            $0.messageClient.presentError = { message in
                errorMessage.withValue { $0 = message }
            }
        }

        await store.send(.queryChanged(query: "stack")) {
            $0.query = "stack"
        }
        await store.send(.queryChangeDebounced) {
            $0.searchRequestInFlight = true
        }
        await store.receive(.searchResponse(.success([.fixtureStacktrace, .fixtureStackOverflow]))) {
            $0.searchRequestInFlight = false
            $0.showsState = .loaded(shows: [.fixtureStacktrace, .fixtureStackOverflow])
        }
        await store.send(.queryChanged(query: "error")) {
            $0.query = "error"
        }
        await store.send(.queryChangeDebounced) {
            $0.searchRequestInFlight = true
        }
        await store.receive(.searchResponse(.failure(TestError.somethingWentWrong))) {
            $0.searchRequestInFlight = false
        }

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
        await store.send(.queryChangeDebounced) {
            $0.searchRequestInFlight = true
        }
        await store.send(.queryChanged(query: "")) {
            $0.searchRequestInFlight = false
            $0.query = ""
            $0.showsState = .prompt
        }
        await clock.advance(by: .seconds(1))
    }
}
