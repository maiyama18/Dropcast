import ComposableArchitecture
import TestHelper
import XCTest

@testable import ShowsFeature

@MainActor
final class FollowShowsReducerTests: XCTestCase {
    func test_queryChangeDebounced_searchSuccess() async {
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
            $0.shows = [.fixtureStacktrace, .fixtureStackOverflow]
        }
    }

    func test_queryChangeDebounced_searchFailure() async {
        let store = TestStore(
            initialState: FollowShowsReducer.State(),
            reducer: FollowShowsReducer()
        ) {
            $0.iTunesClient.searchShows = { _ in
                throw TestError.somethingWentWrong
            }
        }

        await store.send(.queryChanged(query: "stack")) {
            $0.query = "stack"
        }
        await store.send(.queryChangeDebounced)
        await store.receive(.searchResponse(.failure(TestError.somethingWentWrong)))
    }
}
