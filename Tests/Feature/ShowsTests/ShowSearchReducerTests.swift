import ComposableArchitecture
import Entity
import Error
import TestHelper
import XCTest

@testable import ShowsFeature

@MainActor
final class ShowSearchReducerTests: XCTestCase {
    func test_search_by_query_success_shows_results_and_empty_query_delete_previous_results() async {
        let store = TestStore(
            initialState: ShowSearchReducer.State(),
            reducer: ShowSearchReducer()
        ) {
            $0.iTunesClient.searchShows = { query in
                XCTAssertNoDifference(query, "stack")
                return .success([.fixtureStacktrace, .fixtureStackOverflow])
            }
        }

        await store.send(.queryChanged(query: "stack")) {
            $0.query = "stack"
        }

        await store.send(.queryChangeDebounced) {
            $0.searchRequestInFlight = true
        }
        await store.receive(.querySearchResponse(.success([.fixtureStacktrace, .fixtureStackOverflow]))) {
            $0.searchRequestInFlight = false
            $0.showsState = .loaded(
                shows: [
                    SimpleShow(
                        feedURL: URL(string: "https://stacktracepodcast.fm/feed.rss")!,
                        imageURL: URL(string: "https://is4-ssl.mzstatic.com/image/thumb/Podcasts122/v4/21/b1/83/"
                                        + "21b183f6-53e2-fe5e-eabb-f7447577c9b7/mza_9137980121963783437.png/100x100bb.jpg")!,
                        title: "Stacktrace",
                        author: "John Sundell and Gui Rambo"
                    ),
                    SimpleShow(
                        feedURL: URL(string: "https://feeds.simplecast.com/XA_851k3")!,
                        imageURL: URL(string: "https://is4-ssl.mzstatic.com/image/thumb/Podcasts116/v4/6d/32/15/"
                                        + "6d32155b-12ec-8d15-2f76-256e8e7f8dcf/mza_16949506039235574720.jpg/100x100bb.jpg")!,
                        title: "The Stack Overflow Podcast",
                        author: "The Stack Overflow Podcast"
                    ),
                ]
            )
        }

        await store.send(.queryChanged(query: "")) {
            $0.query = ""
            $0.showsState = .prompt
        }
    }

    func test_empty_result_shows_empty_view() async {
        let store = TestStore(
            initialState: ShowSearchReducer.State(),
            reducer: ShowSearchReducer()
        ) {
            $0.iTunesClient.searchShows = { query in
                XCTAssertNoDifference(query, "stack")
                return .success([])
            }
        }

        await store.send(.queryChanged(query: "stack")) {
            $0.query = "stack"
        }

        await store.send(.queryChangeDebounced) {
            $0.searchRequestInFlight = true
        }
        await store.receive(.querySearchResponse(.success([]))) {
            $0.searchRequestInFlight = false
            $0.showsState = .empty
        }
    }

    func test_search_failure_shows_error_message() async {
        let errorMessage: LockIsolated<String?> = .init(nil)
        let store = TestStore(
            initialState: ShowSearchReducer.State(),
            reducer: ShowSearchReducer()
        ) {
            $0.iTunesClient.searchShows = { _ in
                return .failure(.networkError(reason: .timeout))
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
        await store.receive(.querySearchResponse(.failure(.networkError(reason: .timeout)))) {
            $0.searchRequestInFlight = false
            $0.showsState = .prompt
        }

        XCTAssertEqual(errorMessage.value, "Request timed out")
    }

    func test_search_failure_after_success_shows_error_message_with_previous_search_results() async {
        let errorMessage: LockIsolated<String?> = .init(nil)
        let store = TestStore(
            initialState: ShowSearchReducer.State(),
            reducer: ShowSearchReducer()
        ) {
            $0.iTunesClient.searchShows = { query in
                if query == "stack" {
                    return .success([.fixtureStacktrace, .fixtureStackOverflow])
                } else {
                    return .failure(.parseError)
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
        await store.receive(.querySearchResponse(.success([.fixtureStacktrace, .fixtureStackOverflow]))) {
            $0.searchRequestInFlight = false
            $0.showsState = .loaded(
                shows: [
                    SimpleShow(
                        feedURL: URL(string: "https://stacktracepodcast.fm/feed.rss")!,
                        imageURL: URL(string: "https://is4-ssl.mzstatic.com/image/thumb/Podcasts122/v4/21/b1/83/"
                                        + "21b183f6-53e2-fe5e-eabb-f7447577c9b7/mza_9137980121963783437.png/100x100bb.jpg")!,
                        title: "Stacktrace",
                        author: "John Sundell and Gui Rambo"
                    ),
                    SimpleShow(
                        feedURL: URL(string: "https://feeds.simplecast.com/XA_851k3")!,
                        imageURL: URL(string: "https://is4-ssl.mzstatic.com/image/thumb/Podcasts116/v4/6d/32/15/"
                                        + "6d32155b-12ec-8d15-2f76-256e8e7f8dcf/mza_16949506039235574720.jpg/100x100bb.jpg")!,
                        title: "The Stack Overflow Podcast",
                        author: "The Stack Overflow Podcast"
                    ),
                ]
            )
        }
        await store.send(.queryChanged(query: "error")) {
            $0.query = "error"
        }
        await store.send(.queryChangeDebounced) {
            $0.searchRequestInFlight = true
        }
        await store.receive(.querySearchResponse(.failure(.parseError))) {
            $0.searchRequestInFlight = false
        }

        XCTAssertEqual(errorMessage.value, "Invalid server response")
    }

    func test_query_changed_to_empty_while_searching_cancels_search() async {
        let clock = TestClock()

        let store = TestStore(
            initialState: ShowSearchReducer.State(),
            reducer: ShowSearchReducer()
        ) {
            $0.iTunesClient.searchShows = { query in
                XCTAssertNoDifference(query, "stack")
                try? await clock.sleep(for: .seconds(1))
                return .success([.fixtureStacktrace, .fixtureStackOverflow])
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
            initialState: ShowSearchReducer.State(),
            reducer: ShowSearchReducer()
        ) {
            $0.rssClient.fetch = { url in
                XCTAssertNoDifference(url, URL(string: "https://feeds.rebuild.fm/rebuildfm"))
                return .success(.fixtureRebuild)
            }
        }

        await store.send(.queryChanged(query: "https://feeds.rebuild.fm/rebuildfm")) {
            $0.query = "https://feeds.rebuild.fm/rebuildfm"
        }

        await store.send(.queryChangeDebounced) {
            $0.searchRequestInFlight = true
        }
        await store.receive(.urlSearchResponse(.success(.fixtureRebuild))) {
            $0.searchRequestInFlight = false
            $0.showsState = .loaded(
                shows: [
                    SimpleShow(
                        feedURL: URL(string: "https://feeds.rebuild.fm/rebuildfm")!,
                        imageURL: URL(string: "https://cdn.rebuild.fm/images/icon1400.jpg")!,
                        title: "Rebuild",
                        author: "Tatsuhiko Miyagawa"
                    ),
                ]
            )
        }
    }

    func test_query_parsed_as_invalid_url_shows_empty_view() async {
        let store = TestStore(
            initialState: ShowSearchReducer.State(),
            reducer: ShowSearchReducer()
        ) {
            $0.rssClient.fetch = { url in
                XCTAssertNoDifference(url, URL(string: "https://feeds.rebuild.fm/reb"))
                return .failure(RSSError.invalidFeed)
            }
        }

        await store.send(.queryChanged(query: "https://feeds.rebuild.fm/reb")) {
            $0.query = "https://feeds.rebuild.fm/reb"
        }

        await store.send(.queryChangeDebounced) {
            $0.searchRequestInFlight = true
        }
        await store.receive(.urlSearchResponse(.failure(RSSError.invalidFeed))) {
            $0.searchRequestInFlight = false
            $0.showsState = .empty
        }
    }
    func test_query_with_http_url_fetches_rss() async {
        let store = TestStore(
            initialState: ShowSearchReducer.State(),
            reducer: ShowSearchReducer()
        ) {
            $0.rssClient.fetch = { url in
                XCTAssertNoDifference(url, URL(string: "http://feeds.rebuild.fm/rebuildfm"))
                return .success(.fixtureRebuild)
            }
        }

        await store.send(.queryChanged(query: "http://feeds.rebuild.fm/rebuildfm")) {
            $0.query = "http://feeds.rebuild.fm/rebuildfm"
        }

        await store.send(.queryChangeDebounced) {
            $0.searchRequestInFlight = true
        }
        await store.receive(.urlSearchResponse(.success(.fixtureRebuild))) {
            $0.searchRequestInFlight = false
            $0.showsState = .loaded(shows: [
                SimpleShow(
                    feedURL: URL(string: "https://feeds.rebuild.fm/rebuildfm")!,
                    imageURL: URL(string: "https://cdn.rebuild.fm/images/icon1400.jpg")!,
                    title: "Rebuild",
                    author: "Tatsuhiko Miyagawa"
                ),
            ])
        }
    }

    func test_tapping_show_makes_transition() async {
        let store = TestStore(
            initialState: ShowSearchReducer.State(),
            reducer: ShowSearchReducer()
        ) {
            $0.iTunesClient.searchShows = { query in
                XCTAssertNoDifference(query, "stack")
                return .success([.fixtureStacktrace, .fixtureStackOverflow])
            }
        }

        store.exhaustivity = .off

        await store.send(.queryChanged(query: "stack")) {
            $0.query = "stack"
        }
        await store.send(.queryChangeDebounced) {
            $0.searchRequestInFlight = true
        }
        await store.receive(.querySearchResponse(.success([.fixtureStacktrace, .fixtureStackOverflow])))

        store.exhaustivity = .on

        await store.send(.showDetailSelected(feedURL: ITunesShow.fixtureStacktrace.feedURL)) {
            $0.selectedShowState = Identified(
                .init(
                    feedURL: ITunesShow.fixtureStacktrace.feedURL,
                    imageURL: ITunesShow.fixtureStacktrace.artworkLowQualityURL,
                    title: ITunesShow.fixtureStacktrace.showName,
                    episodes: [],
                    author: ITunesShow.fixtureStacktrace.artistName
                ),
                id: ITunesShow.fixtureStacktrace.feedURL
            )
        }
    }
}
