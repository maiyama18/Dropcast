import ComposableArchitecture
import DatabaseClient
import Entity
import Error
import TestHelper
import XCTest

@testable import ShowDetailFeature

@MainActor
final class ShowDetailReducerTests: XCTestCase {
    func test_transition_from_search() async {
        let clock = TestClock()
        let store = TestStore(
            initialState: ShowDetailReducer.State(
                feedURL: ITunesShow.fixtureRebuild.feedURL,
                imageURL: ITunesShow.fixtureRebuild.artworkLowQualityURL,
                title: ITunesShow.fixtureRebuild.showName,
                episodes: [],
                author: ITunesShow.fixtureRebuild.artistName
            ),
            reducer: ShowDetailReducer()
        ) {
            $0.databaseClient = .live(persistentProvider: InMemoryPersistentProvider())

            $0.rssClient.fetch = { url in
                XCTAssertEqual(url, ITunesShow.fixtureRebuild.feedURL)
                try await clock.sleep(for: .seconds(1))
                return Show.fixtureRebuild
            }
        }

        let task = await store.send(.task) {
            $0.taskRequestInFlight = true
        }
        await store.receive(.databaseShowResponse(.success(nil))) {
            $0.followed = false
        }
        await store.receive(.downloadStatesResponse([:])) {
            $0.downloadStates = [:]
        }
        await clock.advance(by: .seconds(1))
        await store.receive(.rssShowResponse(.success(.fixtureRebuild))) {
            $0.taskRequestInFlight = false

            $0.imageURL = Show.fixtureRebuild.imageURL
            $0.title = Show.fixtureRebuild.title
            $0.author = Show.fixtureRebuild.author
            $0.linkURL = Show.fixtureRebuild.linkURL
            $0.description = Show.fixtureRebuild.description
            $0.episodes = Show.fixtureRebuild.episodes
        }
        
        await task.cancel()
    }

    func test_transition_from_list() async {
        let clock = TestClock()
        let store = TestStore(
            initialState: ShowDetailReducer.State(
                feedURL: Show.fixtureRebuild.feedURL,
                imageURL: Show.fixtureRebuild.imageURL,
                title: Show.fixtureRebuild.title,
                episodes: Show.fixtureRebuild.episodes,
                author: Show.fixtureRebuild.author,
                description: Show.fixtureRebuild.description,
                linkURL: Show.fixtureRebuild.linkURL
            ),
            reducer: ShowDetailReducer()
        ) {
            $0.databaseClient = .live(persistentProvider: InMemoryPersistentProvider())
            do {
                try $0.databaseClient.followShow(.fixtureRebuild)
            } catch {
                XCTFail()
            }

            $0.rssClient.fetch = { url in
                XCTAssertEqual(url, ITunesShow.fixtureRebuild.feedURL)
                try await clock.sleep(for: .seconds(1))
                return Show.fixtureRebuild
            }
        }

        let task = await store.send(.task) {
            $0.taskRequestInFlight = true
        }
        await store.receive(.databaseShowResponse(.success(.fixtureRebuild))) {
            $0.followed = true
        }
        await store.receive(.downloadStatesResponse([:])) {
            $0.downloadStates = [:]
        }
        await clock.advance(by: .seconds(1))
        await store.receive(.rssShowResponse(.success(.fixtureRebuild))) {
            $0.taskRequestInFlight = false
        }
        
        await task.cancel()
    }

    func test_show_existing_in_database_is_considered_followed() async {
        let clock = TestClock()
        let store = TestStore(
            initialState: ShowDetailReducer.State(
                feedURL: ITunesShow.fixtureRebuild.feedURL,
                imageURL: ITunesShow.fixtureRebuild.artworkLowQualityURL,
                title: ITunesShow.fixtureRebuild.showName,
                episodes: [],
                author: ITunesShow.fixtureRebuild.artistName
            ),
            reducer: ShowDetailReducer()
        ) {
            $0.databaseClient = .live(persistentProvider: InMemoryPersistentProvider())
            do {
                try $0.databaseClient.followShow(.fixtureRebuild)
            } catch {
                XCTFail()
            }

            $0.rssClient.fetch = { url in
                XCTAssertEqual(url, ITunesShow.fixtureRebuild.feedURL)
                try await clock.sleep(for: .seconds(1))
                return Show.fixtureRebuild
            }
        }

        let task = await store.send(.task) {
            $0.taskRequestInFlight = true
        }
        await store.receive(.databaseShowResponse(.success(.fixtureRebuild))) {
            $0.followed = true

            $0.imageURL = Show.fixtureRebuild.imageURL
            $0.title = Show.fixtureRebuild.title
            $0.author = Show.fixtureRebuild.author
            $0.linkURL = Show.fixtureRebuild.linkURL
            $0.description = Show.fixtureRebuild.description
            $0.episodes = Show.fixtureRebuild.episodes
        }
        await store.receive(.downloadStatesResponse([:])) {
            $0.downloadStates = [:]
        }
        await clock.advance(by: .seconds(1))
        await store.receive(.rssShowResponse(.success(.fixtureRebuild))) {
            $0.taskRequestInFlight = false
        }
        
        await task.cancel()
    }

    func test_database_fetch_error_makes_follow_state_remain_unknown_while_showing_error_message() async {
        let errorMessage: LockIsolated<String?> = .init(nil)
        let clock = TestClock()
        let store = TestStore(
            initialState: ShowDetailReducer.State(
                feedURL: ITunesShow.fixtureRebuild.feedURL,
                imageURL: ITunesShow.fixtureRebuild.artworkLowQualityURL,
                title: ITunesShow.fixtureRebuild.showName,
                episodes: [],
                author: ITunesShow.fixtureRebuild.artistName
            ),
            reducer: ShowDetailReducer()
        ) {
            $0.databaseClient.fetchShow = { _ in throw TestError.somethingWentWrong }

            $0.rssClient.fetch = { url in
                XCTAssertEqual(url, Show.fixtureRebuild.feedURL)
                return Show.fixtureRebuild
            }

            $0.messageClient.presentError = { message in
                errorMessage.withValue { $0 = message }
            }
        }

        let task = await store.send(.task) {
            $0.taskRequestInFlight = true
        }
        await store.receive(.databaseShowResponse(.failure(TestError.somethingWentWrong)))
        await store.receive(.downloadStatesResponse([:])) {
            $0.downloadStates = [:]
        }
        await clock.advance(by: .seconds(1))
        await store.receive(.rssShowResponse(.success(.fixtureRebuild))) {
            $0.taskRequestInFlight = false

            $0.imageURL = Show.fixtureRebuild.imageURL
            $0.title = Show.fixtureRebuild.title
            $0.author = Show.fixtureRebuild.author
            $0.linkURL = Show.fixtureRebuild.linkURL
            $0.description = Show.fixtureRebuild.description
            $0.episodes = Show.fixtureRebuild.episodes
        }

        XCTAssertEqual(errorMessage.value, "Something went wrong")
        
        await task.cancel()
    }

    func test_rss_fetch_error_shows_error_message() async {
        let errorMessage: LockIsolated<String?> = .init(nil)
        let clock = TestClock()
        let store = TestStore(
            initialState: ShowDetailReducer.State(
                feedURL: ITunesShow.fixtureRebuild.feedURL,
                imageURL: ITunesShow.fixtureRebuild.artworkLowQualityURL,
                title: ITunesShow.fixtureRebuild.showName,
                episodes: [],
                author: ITunesShow.fixtureRebuild.artistName
            ),
            reducer: ShowDetailReducer()
        ) {
            $0.databaseClient = .live(persistentProvider: InMemoryPersistentProvider())

            $0.rssClient.fetch = { _ in
                try await clock.sleep(for: .seconds(1))
                throw RSSError.fetchError
            }

            $0.messageClient.presentError = { message in
                errorMessage.withValue { $0 = message }
            }
        }

        let test = await store.send(.task) {
            $0.taskRequestInFlight = true
        }
        await store.receive(.databaseShowResponse(.success(nil))) {
            $0.followed = false
        }
        await store.receive(.downloadStatesResponse([:])) {
            $0.downloadStates = [:]
        }
        await clock.advance(by: .seconds(1))
        await store.receive(.rssShowResponse(.failure(RSSError.fetchError))) {
            $0.taskRequestInFlight = false
        }

        XCTAssertEqual(errorMessage.value, "Failed to fetch information about this show")
        
        await test.cancel()
    }

    func test_following_show() async {
        let databaseClient: DatabaseClient = .live(persistentProvider: InMemoryPersistentProvider())
        let store = TestStore(
            initialState: ShowDetailReducer.State(
                feedURL: ITunesShow.fixtureRebuild.feedURL,
                imageURL: ITunesShow.fixtureRebuild.artworkLowQualityURL,
                title: ITunesShow.fixtureRebuild.showName,
                episodes: [],
                author: ITunesShow.fixtureRebuild.artistName
            ),
            reducer: ShowDetailReducer()
        ) {
            $0.databaseClient = databaseClient

            $0.rssClient.fetch = { url in
                XCTAssertEqual(url, ITunesShow.fixtureRebuild.feedURL)
                return Show.fixtureRebuild
            }
        }

        store.exhaustivity = .off

        let task = await store.send(.task)
        await store.receive(.databaseShowResponse(.success(nil)))
        await store.receive(.downloadStatesResponse([:])) {
            $0.downloadStates = [:]
        }
        await store.receive(.rssShowResponse(.success(.fixtureRebuild)))

        store.exhaustivity = .on

        await store.send(.toggleFollowButtonTapped)
        await store.receive(.toggleFollowResponse(.success(true))) {
            $0.followed = true
        }

        XCTAssertEqual(try databaseClient.fetchShow(Show.fixtureRebuild.feedURL)?.episodes.count, Show.fixtureRebuild.episodes.count)
        
        await task.cancel()
    }

    func test_following_show_failure_shows_error_message() async {
        let errorMessage: LockIsolated<String?> = .init(nil)
        let store = TestStore(
            initialState: ShowDetailReducer.State(
                feedURL: ITunesShow.fixtureRebuild.feedURL,
                imageURL: ITunesShow.fixtureRebuild.artworkLowQualityURL,
                title: ITunesShow.fixtureRebuild.showName,
                episodes: [],
                author: ITunesShow.fixtureRebuild.artistName
            ),
            reducer: ShowDetailReducer()
        ) {
            $0.databaseClient.fetchShow = { _ in nil }
            $0.databaseClient.followShow = { _ in throw DatabaseError.followError }

            $0.rssClient.fetch = { url in
                XCTAssertEqual(url, ITunesShow.fixtureRebuild.feedURL)
                return Show.fixtureRebuild
            }

            $0.messageClient.presentError = { message in
                errorMessage.withValue { $0 = message }
            }
        }

        store.exhaustivity = .off

        let task = await store.send(.task)
        await store.receive(.databaseShowResponse(.success(nil)))
        await store.receive(.downloadStatesResponse([:])) {
            $0.downloadStates = [:]
        }
        await store.receive(.rssShowResponse(.success(.fixtureRebuild)))

        store.exhaustivity = .on

        await store.send(.toggleFollowButtonTapped)
        await store.receive(.toggleFollowResponse(.failure(DatabaseError.followError)))

        XCTAssertEqual(errorMessage.value, "Failed to follow the show")
        
        await task.cancel()
    }

    func test_unfollowing_show() async {
        let databaseClient: DatabaseClient = .live(persistentProvider: InMemoryPersistentProvider())
        let store = TestStore(
            initialState: ShowDetailReducer.State(
                feedURL: ITunesShow.fixtureRebuild.feedURL,
                imageURL: ITunesShow.fixtureRebuild.artworkLowQualityURL,
                title: ITunesShow.fixtureRebuild.showName,
                episodes: [],
                author: ITunesShow.fixtureRebuild.artistName
            ),
            reducer: ShowDetailReducer()
        ) {
            $0.databaseClient = databaseClient
            do {
                try $0.databaseClient.followShow(.fixtureRebuild)
            } catch {
                XCTFail()
            }

            $0.rssClient.fetch = { url in
                XCTAssertEqual(url, ITunesShow.fixtureRebuild.feedURL)
                return Show.fixtureRebuild
            }
        }

        XCTAssertEqual(try databaseClient.fetchShow(Show.fixtureRebuild.feedURL), .fixtureRebuild)

        store.exhaustivity = .off

        let task = await store.send(.task)
        await store.receive(.databaseShowResponse(.success(.fixtureRebuild)))
        await store.receive(.rssShowResponse(.success(.fixtureRebuild)))

        store.exhaustivity = .on

        await store.send(.toggleFollowButtonTapped)
        await store.receive(.toggleFollowResponse(.success(true))) {
            $0.followed = false
        }

        XCTAssertEqual(try databaseClient.fetchShow(Show.fixtureRebuild.feedURL), nil)
        
        await task.cancel()
    }

    func test_copy_feed_url() async {
        let copiedString: LockIsolated<String?> = .init(nil)
        let successTitle: LockIsolated<String?> = .init(nil)
        let store = TestStore(
            initialState: ShowDetailReducer.State(
                feedURL: ITunesShow.fixtureRebuild.feedURL,
                imageURL: ITunesShow.fixtureRebuild.artworkLowQualityURL,
                title: ITunesShow.fixtureRebuild.showName,
                episodes: [],
                author: ITunesShow.fixtureRebuild.artistName
            ),
            reducer: ShowDetailReducer()
        ) {
            $0.databaseClient = .live(persistentProvider: InMemoryPersistentProvider())

            $0.rssClient.fetch = { url in
                XCTAssertEqual(url, ITunesShow.fixtureRebuild.feedURL)
                return Show.fixtureRebuild
            }

            $0.messageClient.presentSuccess = { title in successTitle.withValue { $0 = title } }

            $0.clipboardClient.copy = { string in copiedString.withValue { $0 = string } }
            $0.clipboardClient.copiedString = { copiedString.value }
        }

        store.exhaustivity = .off

        let task = await store.send(.task)
        await store.receive(.databaseShowResponse(.success(nil)))
        await store.receive(.rssShowResponse(.success(.fixtureRebuild)))

        store.exhaustivity = .on

        await store.send(.copyFeedURLButtonTapped)

        XCTAssertEqual(copiedString.value, ITunesShow.fixtureRebuild.feedURL.absoluteString)
        XCTAssertEqual(successTitle.value, "Copied")
        
        await task.cancel()
    }

    func test_in_flight_rss_request_cancelled_on_disappear() async {
        let clock = TestClock()
        let store = TestStore(
            initialState: ShowDetailReducer.State(
                feedURL: ITunesShow.fixtureRebuild.feedURL,
                imageURL: ITunesShow.fixtureRebuild.artworkLowQualityURL,
                title: ITunesShow.fixtureRebuild.showName,
                episodes: [],
                author: ITunesShow.fixtureRebuild.artistName
            ),
            reducer: ShowDetailReducer()
        ) {
            $0.databaseClient = .live(persistentProvider: InMemoryPersistentProvider())

            $0.rssClient.fetch = { url in
                XCTAssertEqual(url, ITunesShow.fixtureRebuild.feedURL)
                try await clock.sleep(for: .seconds(1))
                return Show.fixtureRebuild
            }
        }

        let task = await store.send(.task) {
            $0.taskRequestInFlight = true
        }
        await store.receive(.databaseShowResponse(.success(nil))) {
            $0.followed = false
        }
        await store.receive(.downloadStatesResponse([:])) {
            $0.downloadStates = [:]
        }
        await store.send(.disappear)
        await clock.advance(by: .seconds(1))
        // no rss response should be received
        
        await task.cancel()
    }
}
