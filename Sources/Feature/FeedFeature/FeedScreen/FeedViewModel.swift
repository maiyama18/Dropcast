import Combine
import DeepLink
import Dependencies
import Entity
import Extension
import Foundation
import IdentifiedCollections
import MessageClient
import Observation
import RSSClient
import SoundFileClient
import UserDefaultsClient

@MainActor
@Observable
final class FeedViewModel {
    enum Action {
        case appear
        case pullToRefresh
        case tapAddShowButton
        case tapDownloadEpisodeButton(episode: Episode)
    }

    private(set) var episodes: IdentifiedArrayOf<Episode>? = nil
    private var downloadStates: [Episode.ID: EpisodeDownloadState] = [:]

    func downloadState(id: Episode.ID) -> EpisodeDownloadState {
        downloadStates[id] ?? .notDownloaded
    }

    @ObservationIgnored @Dependency(\.date.now) private var now
    @ObservationIgnored @Dependency(\.openURL) private var openURL
    
    @ObservationIgnored @Dependency(\.databaseClient) private var databaseClient
    @ObservationIgnored @Dependency(\.messageClient) private var messageClient
    @ObservationIgnored @Dependency(\.rssClient) private var rssClient
    @ObservationIgnored @Dependency(\.soundFileClient) private var soundFileClient
    @ObservationIgnored @Dependency(\.userDefaultsClient) private var userDefaultsClient

    private var cancellables: Set<AnyCancellable> = .init()

    init() {
        subscribe()
    }

    func handle(action: Action) async {
        switch action {
        case .appear:
            if let feedRefreshedAt = userDefaultsClient.getFeedRefreshedAt(),
               now.timeIntervalSince(feedRefreshedAt) <= 600 {
                return
            }
            await refreshFeed()
        case .pullToRefresh:
            await refreshFeed()
        case .tapAddShowButton:
            await openURL(DeepLink.showSearch)
        case .tapDownloadEpisodeButton(let episode):
            switch downloadState(id: episode.id) {
            case .notDownloaded:
                Task { try await soundFileClient.download(episode) }
            case .pushedToDownloadQueue:
                break
            case .downloading:
                Task { try await soundFileClient.cancelDownload(episode) }
            case .downloaded:
                // TODO: play sound
                break
            }
        }
    }

    private func subscribe() {
        Task { [weak self, databaseClient] in
            for await episodes in databaseClient.followedEpisodesStream() {
                self?.episodes = episodes
            }
        }
        .store(in: &cancellables)

        Task { [weak self, soundFileClient] in
            for await downloadStates in soundFileClient.downloadStatesPublisher.eraseToStream() {
                self?.downloadStates = downloadStates
            }
        }
        .store(in: &cancellables)

        Task { [messageClient, soundFileClient] in
            for await downloadError in soundFileClient.downloadErrorPublisher.eraseToStream() {
                let message: String
                switch downloadError {
                case .unexpectedError:
                    message = String(localized: "Something went wrong", bundle: .module)
                case .downloadError:
                    message = String(localized: "Failed to download the episode", bundle: .module)
                }
                messageClient.presentError(message)
            }
        }
        .store(in: &cancellables)
    }

    private func refreshFeed() async {
        let shows: [Show]
        switch databaseClient.fetchFollowedShows() {
        case .success(let followedShows):
            shows = followedShows.elements
        case .failure:
            messageClient.presentError(String(localized: "Failed to communicate with database", bundle: .module))
            return
        }

        await withTaskGroup(of: Void.self) { [rssClient, databaseClient] group in
            for show in shows {
                group.addTask {
                    switch await rssClient.fetch(show.feedURL) {
                    case .success(let show):
                        _ = databaseClient.addNewEpisodes(show)
                    case .failure:
                        // do not show error when update of one of shows failed
                        break
                    }
                }
            }
        }

        userDefaultsClient.setFeedRefreshedAt(now)
    }
}
