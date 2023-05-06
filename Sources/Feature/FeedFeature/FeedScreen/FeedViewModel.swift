import Combine
import Dependencies
import Entity
import Extension
import IdentifiedCollections
import MessageClient
import RSSClient
import SoundFileClient
import UserDefaultsClient

@MainActor
final class FeedViewModel: ObservableObject {
    enum Action {
        case appear
        case pullToRefresh
    }
    
    enum Event {
    }
    
    @Published private(set) var episodes: IdentifiedArrayOf<Episode>? = nil
    @Published private var downloadStates: [Episode.ID: EpisodeDownloadState] = [:]
    
    func downloadState(id: Episode.ID) -> EpisodeDownloadState {
        downloadStates[id] ?? .notDownloaded
    }
    
    @Dependency(\.date.now) private var now
    
    @Dependency(\.databaseClient) private var databaseClient
    @Dependency(\.messageClient) private var messageClient
    @Dependency(\.rssClient) private var rssClient
    @Dependency(\.soundFileClient) private var soundFileClient
    @Dependency(\.userDefaultsClient) private var userDefaultsClient
    
    private var cancellables: Set<AnyCancellable> = .init()
    
    var eventStream: AsyncStream<Event> { eventSubject.eraseToStream() }
    private let eventSubject: PassthroughSubject<Event, Never> = .init()
    
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
                    message = L10n.Error.somethingWentWrong
                case .downloadError:
                    message = L10n.Error.downloadError
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
            messageClient.presentError(L10n.Error.databaseError)
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
