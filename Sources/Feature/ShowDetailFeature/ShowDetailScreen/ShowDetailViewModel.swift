import ClipboardClient
import Combine
import DatabaseClient
import Dependencies
import Entity
import Extension
import Foundation
import MessageClient
import Observation
import RSSClient
import SoundFileClient

@MainActor
@Observable
final class ShowDetailViewModel {
    enum Action {
        case appear
        case tapToggleFollowButton
        case tapCopyFeedURLButton
        case tapDownloadEpisodeButton(episode: Episode)
    }

    let feedURL: URL
    let imageURL: URL
    let title: String

    /// この画面においてエピソードのダウンロードや再生が可能かどうかを表す。
    /// 検索画面から遷移した場合は false になる。
    let showsEpisodeActionButtons: Bool

    private(set) var episodes: [Episode]
    private(set) var author: String?
    private(set) var description: String?
    private(set) var linkURL: URL?
    private(set) var followed: Bool?
    private(set) var isFetchingShow: Bool = false

    private var downloadStates: [Episode.ID: EpisodeDownloadState]?

    func downloadState(id: Episode.ID) -> EpisodeDownloadState {
        guard let downloadStates else { return .notDownloaded }
        return downloadStates[id] ?? .notDownloaded
    }

    private var cancellables: Set<AnyCancellable> = .init()

    @ObservationIgnored @Dependency(\.clipboardClient) private var clipboardClient
    @ObservationIgnored @Dependency(\.databaseClient) private var databaseClient
    @ObservationIgnored @Dependency(\.messageClient) private var messageClient
    @ObservationIgnored @Dependency(\.rssClient) private var rssClient
    @ObservationIgnored @Dependency(\.soundFileClient) private var soundFileClient

    init(
        feedURL: URL,
        imageURL: URL,
        title: String,
        showsEpisodeActionButtons: Bool,
        episodes: [Episode],
        author: String?,
        description: String?,
        linkURL: URL?,
        followed: Bool?
    ) {
        self.feedURL = feedURL
        self.imageURL = imageURL
        self.title = title
        self.showsEpisodeActionButtons = showsEpisodeActionButtons
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
                    message = String(localized: "Something went wrong", bundle: .module)
                case .downloadError:
                    message = String(localized: "Failed to download the episode", bundle: .module)
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
                messageClient.presentError(String(localized: "Failed to connect to database", bundle: .module))
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
                        message = String(localized: "Invalid RSS feed", bundle: .module)
                    case .networkError(reason: let error):
                        message = error.localizedDescription
                    }

                    messageClient.presentError(message)
                }
            }
        case .tapCopyFeedURLButton:
            clipboardClient.copy(feedURL.absoluteString)
            messageClient.presentSuccess(String(localized: "Copied", bundle: .module))
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
                    messageClient.presentError(String(localized: "Failed to unfollow the show", bundle: .module))
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
                    messageClient.presentError(String(localized: "Failed to follow the show", bundle: .module))
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
