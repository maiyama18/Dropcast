import ComposableArchitecture
import DatabaseClient
import Entity
import Error
import SoundFileClient
import TestHelper
import XCTest

@testable import FeedFeature

@MainActor
final class FeedReducerTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1677412800)
    private let userDefaults = UserDefaults(suiteName: "FeedReducerTests")!
    
    override func tearDown() {
        super.tearDown()
        
        userDefaults.removePersistentDomain(forName: "FeedReducerTests")
    }
    
    func test_feed_is_initialized_with_episodes_of_followed_shows() async {
        let store = TestStore(
            initialState: FeedReducer.State(),
            reducer: FeedReducer()
        ) {
            $0.databaseClient = .live(persistentProvider: InMemoryPersistentProvider())
            do {
                try $0.databaseClient.followShow(.fixtureRebuild).get()
            } catch {
                XCTFail()
            }
            
            $0.rssClient.fetch = { feedURL in
                XCTAssertNoDifference(feedURL, Show.fixtureRebuild.feedURL)
                return .success(.fixtureRebuild)
            }
            
            $0.userDefaultsClient = .instance(userDefaults: userDefaults)
            
            $0.date.now = now
        }

        let task = await store.send(.task)
        await store.receive(.downloadStatesResponse([:])) {
            $0.downloadStates = [:]
        }
        await store.receive(.episodesResponse(IdentifiedArrayOf(uniqueElements: [.fixtureRebuild352, .fixtureRebuild351, .fixtureRebuild350]))) {
            $0.episodes = [.fixtureRebuild352, .fixtureRebuild351, .fixtureRebuild350]
        }

        await task.cancel()
    }
    
    func test_new_episodes_are_prepended_to_feed() async throws {
        let clock = TestClock()
        let databaseClient: DatabaseClient = .live(persistentProvider: InMemoryPersistentProvider())
        let store = TestStore(
            initialState: FeedReducer.State(),
            reducer: FeedReducer()
        ) {
            $0.databaseClient = databaseClient
            do {
                var fixtureRebuild: Show = .fixtureRebuild
                fixtureRebuild.episodes = [.fixtureRebuild350]
                var fixtureSwiftBySundell: Show = .fixtureSwiftBySundell
                fixtureSwiftBySundell.episodes = [.fixtureSwiftBySundell121, .fixtureSwiftBySundell122]
                
                try $0.databaseClient.followShow(fixtureRebuild).get()
                try $0.databaseClient.followShow(fixtureSwiftBySundell).get()
            } catch {
                XCTFail()
            }
            
            $0.rssClient.fetch = { feedURL in
                switch feedURL {
                case Show.fixtureRebuild.feedURL:
                    try? await clock.sleep(for: .seconds(1))
                    return .success(.fixtureRebuild)
                case Show.fixtureSwiftBySundell.feedURL:
                    try? await clock.sleep(for: .seconds(2))
                    return .success(.fixtureSwiftBySundell)
                default:
                    XCTFail()
                    return .failure(RSSError.invalidFeed)
                }
            }
            
            $0.userDefaultsClient = .instance(userDefaults: userDefaults)
            
            $0.date.now = now
        }

        let task = await store.send(.task)
        await store.receive(.downloadStatesResponse([:])) {
            $0.downloadStates = [:]
        }
        await store.receive(
            .episodesResponse(IdentifiedArrayOf(uniqueElements: [
                .fixtureRebuild350,
                .fixtureSwiftBySundell122,
                .fixtureSwiftBySundell121,
            ]))
        ) {
            $0.episodes = [
                .fixtureRebuild350,
                .fixtureSwiftBySundell122,
                .fixtureSwiftBySundell121,
            ]
        }
        
        await clock.advance(by: .seconds(1))
        
        await store.receive(
            .episodesResponse(IdentifiedArrayOf(uniqueElements: [
                .fixtureRebuild352,
                .fixtureRebuild351,
                .fixtureRebuild350,
                .fixtureSwiftBySundell122,
                .fixtureSwiftBySundell121,
            ]))
        ) {
            $0.episodes = [
                .fixtureRebuild352,
                .fixtureRebuild351,
                .fixtureRebuild350,
                .fixtureSwiftBySundell122,
                .fixtureSwiftBySundell121,
            ]
        }
        
        await clock.advance(by: .seconds(1))
        
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
    
    func test_new_episodes_are_not_fetched_on_appear_if_feed_was_recently_refreshed_but_ptr_refreshes_feed_forcibly() async throws {
        let clock = TestClock()
        let databaseClient: DatabaseClient = .live(persistentProvider: InMemoryPersistentProvider())
        let store = TestStore(
            initialState: FeedReducer.State(),
            reducer: FeedReducer()
        ) {
            $0.databaseClient = databaseClient
            do {
                var fixtureRebuild: Show = .fixtureRebuild
                fixtureRebuild.episodes = [.fixtureRebuild350]
                var fixtureSwiftBySundell: Show = .fixtureSwiftBySundell
                fixtureSwiftBySundell.episodes = [.fixtureSwiftBySundell121, .fixtureSwiftBySundell122]
                
                try $0.databaseClient.followShow(fixtureRebuild).get()
                try $0.databaseClient.followShow(fixtureSwiftBySundell).get()
            } catch {
                XCTFail()
            }
            
            $0.rssClient.fetch = { feedURL in
                switch feedURL {
                case Show.fixtureRebuild.feedURL:
                    try? await clock.sleep(for: .seconds(1))
                    return .success(.fixtureRebuild)
                case Show.fixtureSwiftBySundell.feedURL:
                    try? await clock.sleep(for: .seconds(2))
                    return .success(.fixtureSwiftBySundell)
                default:
                    XCTFail()
                    return .failure(RSSError.invalidFeed)
                }
            }
            
            $0.userDefaultsClient = .instance(userDefaults: userDefaults)
            $0.userDefaultsClient.setFeedRefreshedAt(now.addingTimeInterval(-600))
            
            $0.date.now = now
        }

        let task = await store.send(.task)
        await store.receive(.downloadStatesResponse([:])) {
            $0.downloadStates = [:]
        }
        await store.receive(
            .episodesResponse(IdentifiedArrayOf(uniqueElements: [
                .fixtureRebuild350,
                .fixtureSwiftBySundell122,
                .fixtureSwiftBySundell121,
            ]))
        ) {
            $0.episodes = [
                .fixtureRebuild350,
                .fixtureSwiftBySundell122,
                .fixtureSwiftBySundell121,
            ]
        }
        
        await clock.advance(by: .seconds(2))
        
        await store.send(.pullToRefreshed)
        
        await clock.advance(by: .seconds(1))
        
        await store.receive(
            .episodesResponse(IdentifiedArrayOf(uniqueElements: [
                .fixtureRebuild352,
                .fixtureRebuild351,
                .fixtureRebuild350,
                .fixtureSwiftBySundell122,
                .fixtureSwiftBySundell121,
            ]))
        ) {
            $0.episodes = [
                .fixtureRebuild352,
                .fixtureRebuild351,
                .fixtureRebuild350,
                .fixtureSwiftBySundell122,
                .fixtureSwiftBySundell121,
            ]
        }
        
        await clock.advance(by: .seconds(1))
        
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

    func test_episodes_of_followed_shows_are_added_to_feed() async throws {
        let databaseClient: DatabaseClient = .live(persistentProvider: InMemoryPersistentProvider())
        let store = TestStore(
            initialState: FeedReducer.State(),
            reducer: FeedReducer()
        ) {
            $0.databaseClient = databaseClient
            do {
                try $0.databaseClient.followShow(.fixtureRebuild).get()
            } catch {
                XCTFail()
            }
            
            $0.rssClient.fetch = { feedURL in
                XCTAssertNoDifference(feedURL, Show.fixtureRebuild.feedURL)
                return .success(.fixtureRebuild)
            }
            
            $0.userDefaultsClient = .instance(userDefaults: userDefaults)
            
            $0.date.now = now
        }

        let task = await store.send(.task)
        await store.receive(.downloadStatesResponse([:])) {
            $0.downloadStates = [:]
        }
        await store.receive(.episodesResponse(IdentifiedArrayOf(uniqueElements: [.fixtureRebuild352, .fixtureRebuild351, .fixtureRebuild350]))) {
            $0.episodes = [.fixtureRebuild352, .fixtureRebuild351, .fixtureRebuild350]
        }

        try databaseClient.followShow(.fixtureSwiftBySundell).get()
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
                try $0.databaseClient.followShow(.fixtureRebuild).get()
                try $0.databaseClient.followShow(.fixtureSwiftBySundell).get()
            } catch {
                XCTFail()
            }
            
            $0.rssClient.fetch = { feedURL in
                switch feedURL {
                case Show.fixtureRebuild.feedURL:
                    return .success(.fixtureRebuild)
                case Show.fixtureSwiftBySundell.feedURL:
                    return .success(.fixtureSwiftBySundell)
                default:
                    XCTFail()
                    return .failure(RSSError.invalidFeed)
                }
            }
            
            $0.userDefaultsClient = .instance(userDefaults: userDefaults)
            
            $0.date.now = now
        }

        let task = await store.send(.task)
        await store.receive(.downloadStatesResponse([:])) {
            $0.downloadStates = [:]
        }
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

        try databaseClient.unfollowShow(Show.fixtureSwiftBySundell.feedURL).get()
        await store.receive(.episodesResponse(IdentifiedArrayOf(uniqueElements: [.fixtureRebuild352, .fixtureRebuild351, .fixtureRebuild350]))) {
            $0.episodes = [.fixtureRebuild352, .fixtureRebuild351, .fixtureRebuild350]
        }

        await task.cancel()
    }

    func test_download_success() async throws {
        let clock = TestClock()
        let soundFileClient: SoundFileClient = withDependencies {
            $0.continuousClock = clock
        } operation: {
            SoundFileClientMock()
        }

        let databaseClient: DatabaseClient = .live(persistentProvider: InMemoryPersistentProvider())
        let store = TestStore(
            initialState: FeedReducer.State(),
            reducer: FeedReducer()
        ) {
            $0.soundFileClient = soundFileClient

            $0.databaseClient = databaseClient
            do {
                try $0.databaseClient.followShow(.fixtureRebuild).get()
            } catch {
                XCTFail()
            }
            
            $0.rssClient.fetch = { feedURL in
                XCTAssertNoDifference(feedURL, Show.fixtureRebuild.feedURL)
                return .success(.fixtureRebuild)
            }
            
            $0.userDefaultsClient = .instance(userDefaults: userDefaults)
            
            $0.date.now = now
        }

        let task = await store.send(.task)
        await store.receive(.downloadStatesResponse([:])) {
            $0.downloadStates = [:]
        }
        await store.receive(
            .episodesResponse(IdentifiedArrayOf(uniqueElements: [
                .fixtureRebuild352,
                .fixtureRebuild351,
                .fixtureRebuild350,
            ]))
        ) {
            $0.episodes = [
                .fixtureRebuild352,
                .fixtureRebuild351,
                .fixtureRebuild350,
            ]
        }

        await store.send(.downloadEpisodeButtonTapped(episode: .fixtureRebuild352))
        await store.receive(.downloadStatesResponse([Episode.fixtureRebuild352.id: .pushedToDownloadQueue])) {
            $0.downloadStates = [Episode.fixtureRebuild352.id: .pushedToDownloadQueue]
        }
        await clock.advance(by: .seconds(1))
        await store.receive(.downloadStatesResponse([Episode.fixtureRebuild352.id: .downloading(progress: 0)])) {
            $0.downloadStates = [Episode.fixtureRebuild352.id: .downloading(progress: 0)]
        }
        await clock.advance(by: .seconds(5))
        await store.receive(.downloadStatesResponse([Episode.fixtureRebuild352.id: .downloading(progress: 0.5)])) {
            $0.downloadStates = [Episode.fixtureRebuild352.id: .downloading(progress: 0.5)]
        }
        await clock.advance(by: .seconds(5))
        await store.receive(.downloadStatesResponse([Episode.fixtureRebuild352.id: .downloaded])) {
            $0.downloadStates = [Episode.fixtureRebuild352.id: .downloaded]
        }

        await task.cancel()
    }

    func test_download_cancel() async throws {
        let clock = TestClock()
        let soundFileClient: SoundFileClient = withDependencies {
            $0.continuousClock = clock
        } operation: {
            SoundFileClientMock()
        }

        let databaseClient: DatabaseClient = .live(persistentProvider: InMemoryPersistentProvider())
        let store = TestStore(
            initialState: FeedReducer.State(),
            reducer: FeedReducer()
        ) {
            $0.soundFileClient = soundFileClient

            $0.databaseClient = databaseClient
            do {
                try $0.databaseClient.followShow(.fixtureRebuild).get()
            } catch {
                XCTFail()
            }
            
            $0.rssClient.fetch = { feedURL in
                XCTAssertNoDifference(feedURL, Show.fixtureRebuild.feedURL)
                return .success(.fixtureRebuild)
            }
            
            $0.userDefaultsClient = .instance(userDefaults: userDefaults)
            
            $0.date.now = now
        }

        let task = await store.send(.task)
        await store.receive(.downloadStatesResponse([:])) {
            $0.downloadStates = [:]
        }
        await store.receive(
            .episodesResponse(IdentifiedArrayOf(uniqueElements: [
                .fixtureRebuild352,
                .fixtureRebuild351,
                .fixtureRebuild350,
            ]))
        ) {
            $0.episodes = [
                .fixtureRebuild352,
                .fixtureRebuild351,
                .fixtureRebuild350,
            ]
        }

        await store.send(.downloadEpisodeButtonTapped(episode: .fixtureRebuild352))
        await store.receive(.downloadStatesResponse([Episode.fixtureRebuild352.id: .pushedToDownloadQueue])) {
            $0.downloadStates = [Episode.fixtureRebuild352.id: .pushedToDownloadQueue]
        }

        // has no effect
        await store.send(.downloadEpisodeButtonTapped(episode: .fixtureRebuild352))

        await clock.advance(by: .seconds(1))
        await store.receive(.downloadStatesResponse([Episode.fixtureRebuild352.id: .downloading(progress: 0)])) {
            $0.downloadStates = [Episode.fixtureRebuild352.id: .downloading(progress: 0)]
        }
        await store.send(.downloadEpisodeButtonTapped(episode: .fixtureRebuild352))
        await store.receive(.downloadStatesResponse([Episode.fixtureRebuild352.id: .notDownloaded])) {
            $0.downloadStates = [Episode.fixtureRebuild352.id: .notDownloaded]
        }

        await task.cancel()
    }

    func test_download_failure() async throws {
        let errorMessage: LockIsolated<String?> = .init(nil)

        let clock = TestClock()
        let soundFileClient: SoundFileClientMock = withDependencies {
            $0.continuousClock = clock
        } operation: {
            SoundFileClientMock()
        }
        await soundFileClient.setError(error: .downloadError)

        let databaseClient: DatabaseClient = .live(persistentProvider: InMemoryPersistentProvider())

        let store = TestStore(
            initialState: FeedReducer.State(),
            reducer: FeedReducer()
        ) {
            $0.soundFileClient = soundFileClient

            $0.databaseClient = databaseClient
            do {
                try $0.databaseClient.followShow(.fixtureRebuild).get()
            } catch {
                XCTFail()
            }
            
            $0.rssClient.fetch = { feedURL in
                XCTAssertNoDifference(feedURL, Show.fixtureRebuild.feedURL)
                return .success(.fixtureRebuild)
            }

            $0.messageClient.presentError = { message in
                errorMessage.withValue { $0 = message }
            }
            
            $0.userDefaultsClient = .instance(userDefaults: userDefaults)
            
            $0.date.now = now
        }

        let task = await store.send(.task)
        await store.receive(.downloadStatesResponse([:])) {
            $0.downloadStates = [:]
        }
        await store.receive(
            .episodesResponse(IdentifiedArrayOf(uniqueElements: [
                .fixtureRebuild352,
                .fixtureRebuild351,
                .fixtureRebuild350,
            ]))
        ) {
            $0.episodes = [
                .fixtureRebuild352,
                .fixtureRebuild351,
                .fixtureRebuild350,
            ]
        }

        await store.send(.downloadEpisodeButtonTapped(episode: .fixtureRebuild352))
        await store.receive(.downloadStatesResponse([Episode.fixtureRebuild352.id: .pushedToDownloadQueue])) {
            $0.downloadStates = [Episode.fixtureRebuild352.id: .pushedToDownloadQueue]
        }
        await clock.advance(by: .seconds(1))
        await store.receive(.downloadStatesResponse([Episode.fixtureRebuild352.id: .downloading(progress: 0)])) {
            $0.downloadStates = [Episode.fixtureRebuild352.id: .downloading(progress: 0)]
        }
        await clock.advance(by: .seconds(5))
        await store.receive(.downloadErrorResponse(.downloadError))
        await store.receive(.downloadStatesResponse([Episode.fixtureRebuild352.id: .notDownloaded])) {
            $0.downloadStates = [Episode.fixtureRebuild352.id: .notDownloaded]
        }

        XCTAssertEqual(errorMessage.value, "Failed to download the episode")

        await task.cancel()
    }
}
