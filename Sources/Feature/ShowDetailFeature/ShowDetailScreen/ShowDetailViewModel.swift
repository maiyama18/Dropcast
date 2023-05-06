import ClipboardClient
import Combine
import DatabaseClient
import Dependencies
import Entity
import Extension
import Foundation
import MessageClient
import RSSClient
import SoundFileClient

@MainActor
final class ShowDetailViewModel: ObservableObject {
    enum Action {
        case appear
        case tapToggleFollowButton
        case tapCopyFeedURLButton
        case tapDownloadEpisodeButton(episode: Episode)
    }
    
    enum Event {
    }
    
    let feedURL: URL
    let imageURL: URL
    let title: String
    
    @Published private(set) var episodes: [Episode]
    @Published private(set) var author: String?
    @Published private(set) var description: String?
    @Published private(set) var linkURL: URL?
    @Published private(set) var followed: Bool?
    @Published private(set) var isFetchingShow: Bool = false
    
    @Published private var downloadStates: [Episode.ID: EpisodeDownloadState]?

    func downloadState(id: Episode.ID) -> EpisodeDownloadState {
        guard let downloadStates else { return .notDownloaded }
        return downloadStates[id] ?? .notDownloaded
    }
    
    private var cancellables: Set<AnyCancellable> = .init()
    
    var eventStream: AsyncStream<Event> { eventSubject.eraseToStream() }
    private let eventSubject: PassthroughSubject<Event, Never> = .init()
    
    @Dependency(\.clipboardClient) private var clipboardClient
    @Dependency(\.databaseClient) private var databaseClient
    @Dependency(\.messageClient) private var messageClient
    @Dependency(\.rssClient) private var rssClient
    @Dependency(\.soundFileClient) private var soundFileClient
    
    init(
        feedURL: URL,
        imageURL: URL,
        title: String,
        episodes: [Episode],
        author: String?,
        description: String?,
        linkURL: URL?,
        followed: Bool?
    ) {
        self.feedURL = feedURL
        self.imageURL = imageURL
        self.title = title
        self.episodes = episodes
        self.author = author
        self.description = description
        self.linkURL = linkURL
        self.followed = followed
        
        Task { [weak self, soundFileClient] in
            for await downloadStates in soundFileClient.downloadStatesPublisher.eraseToStream() {
                self?.downloadStates = downloadStates
            }
        }
        .store(in: &cancellables)
        
        Task { [soundFileClient, messageClient] in
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
    
    func handle(action: Action) {
        switch action {
        case .appear:
            switch databaseClient.fetchShow(feedURL) {
            case .success(let show):
                if let show {
                    followed = true
                    reflectShow(show)
                } else {
                    followed = false
                }
            case .failure:
                messageClient.presentError(L10n.Error.databaseError)
            }
            
            Task {
                isFetchingShow = true
                defer { isFetchingShow = false }
                switch await rssClient.fetch(feedURL) {
                case .success(let show):
                    reflectShow(show)
                case .failure(let error):
                    let message: String
                    switch error {
                    case .invalidFeed:
                        message = L10n.Error.invalidRssFeed
                    case .networkError(reason: let error):
                        message = error.localizedDescription
                    }
                    
                    messageClient.presentError(message)
                }
            }
        case .tapCopyFeedURLButton:
            clipboardClient.copy(feedURL.absoluteString)
            messageClient.presentSuccess(L10n.Message.copied)
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
        case .tapToggleFollowButton:
            guard let followed else { return }
            if followed {
                do {
                    try databaseClient.unfollowShow(feedURL).get()
                    self.followed = false
                } catch {
                    messageClient.presentError(L10n.Error.failedToUnfollow)
                }
            } else {
                do {
                    try databaseClient.followShow(
                        Show(
                            title: title,
                            description: description,
                            author: author,
                            feedURL: feedURL,
                            imageURL: imageURL,
                            linkURL: linkURL,
                            episodes: episodes
                        )
                    ).get()
                    self.followed = true
                } catch {
                    messageClient.presentError(L10n.Error.failedToFollow)
                }
            }
        }
    }
    
    private func reflectShow(_ show: Show) {
        author = show.author
        linkURL = show.linkURL
        description = show.description
        episodes = show.episodes
    }
}
