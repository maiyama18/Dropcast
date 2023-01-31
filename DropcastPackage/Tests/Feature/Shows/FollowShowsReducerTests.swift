import ComposableArchitecture
import Entity
import Error
import TestHelper
import XCTest

@testable import ShowsFeature

@MainActor
final class FollowShowsReducerTests: XCTestCase {
    func test_search_by_query_success_shows_results_and_empty_query_delete_previous_results() async {
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

    func test_search_returns_empty_result() async {
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

    func test_search_failure_shows_error_message() async {
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

    func test_search_failure_after_success_shows_error_message_with_previous_search_results() async {
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

    func test_query_changed_to_empty_while_searching_cancels_search() async {
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

    func test_query_parsed_as_url_shows_show_from_rss() async {
        let store = TestStore(
            initialState: FollowShowsReducer.State(),
            reducer: FollowShowsReducer()
        ) {
            $0.rssClient.fetch = { url in
                guard url == URL(string: "https://feeds.rebuild.fm/rebuildfm") else {
                    XCTFail()
                    throw TestError.somethingWentWrong
                }
                return .fixtureRebuild
            }
        }

        await store.send(.queryChanged(query: "https://feeds.rebuild.fm/rebuildfm")) {
            $0.query = "https://feeds.rebuild.fm/rebuildfm"
        }

        await store.send(.queryChangeDebounced) {
            $0.searchRequestInFlight = true
        }
        let fixtureRebuild = ITunesShow(show: .fixtureRebuild)
        await store.receive(.searchResponse(.success([fixtureRebuild]))) {
            $0.searchRequestInFlight = false
            $0.showsState = .loaded(shows: [fixtureRebuild])
        }
    }

    func test_query_parsed_as_invalid_url_shows_empty_show() async {
        let store = TestStore(
            initialState: FollowShowsReducer.State(),
            reducer: FollowShowsReducer()
        ) {
            $0.rssClient.fetch = { url in
                guard url == URL(string: "https://feeds.rebuild.fm/reb") else {
                    XCTFail()
                    throw TestError.somethingWentWrong
                }
                throw RSSError.invalidFeed
            }
        }

        await store.send(.queryChanged(query: "https://feeds.rebuild.fm/reb")) {
            $0.query = "https://feeds.rebuild.fm/reb"
        }

        await store.send(.queryChangeDebounced) {
            $0.searchRequestInFlight = true
        }
        await store.receive(.searchResponse(.success([]))) {
            $0.searchRequestInFlight = false
            $0.showsState = .empty
        }
    }
}
