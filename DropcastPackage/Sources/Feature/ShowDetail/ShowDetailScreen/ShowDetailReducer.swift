import ClipboardClient
import ComposableArchitecture
import DatabaseClient
import Entity
import Error
import Foundation
import MessageClient
import RSSClient
import SoundFileClient

public struct ShowDetailReducer: ReducerProtocol, Sendable {
    public struct State: Equatable {
        public var feedURL: URL
        public var imageURL: URL
        public var title: String
        public var episodes: [Episode]
        public var author: String?
        public var description: String?
        public var linkURL: URL?
        public var followed: Bool? // initially undetermined

        public var taskRequestInFlight: Bool = false

        var downloadStates: [Episode.ID: EpisodeDownloadState]?
        
        public func downloadState(id: Episode.ID) -> EpisodeDownloadState {
            guard let downloadStates else { return .notDownloaded }
            return downloadStates[id] ?? .notDownloaded
        }
        
        public init(
            feedURL: URL,
            imageURL: URL,
            title: String,
            episodes: [Episode],
            author: String? = nil,
            description: String? = nil,
            linkURL: URL? = nil,
            followed: Bool? = nil,
            taskRequestInFlight: Bool = false
        ) {
            self.feedURL = feedURL
            self.imageURL = imageURL
            self.title = title
            self.episodes = episodes
            self.author = author
            self.description = description
            self.linkURL = linkURL
            self.followed = followed
            self.taskRequestInFlight = taskRequestInFlight
        }
    }

    public enum Action: Equatable, Sendable {
        case task
        case disappear
        case toggleFollowButtonTapped
        case copyFeedURLButtonTapped
        case downloadEpisodeButtonTapped(episode: Episode)

        case databaseShowResponse(Result<Show?, DatabaseError>)
        case downloadStatesResponse([String: EpisodeDownloadState])
        case downloadErrorResponse(SoundFileClientError)
        case rssShowResponse(Result<Show, RSSError>)
        case toggleFollowResponse(Result<Bool, DatabaseError>)
    }

    @Dependency(\.clipboardClient) private var clipboardClient
    @Dependency(\.databaseClient) private var databaseClient
    @Dependency(\.messageClient) private var messageClient
    @Dependency(\.rssClient) private var rssClient
    @Dependency(\.soundFileClient) private var soundFileClient

    public init() {}

    private enum RSSRequestID {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                state.taskRequestInFlight = true
                return .merge(
                    .concatenate(
                        .task { [feedURL = state.feedURL] in
                            let result = databaseClient.fetchShow(feedURL)
                            return .databaseShowResponse(result)
                        },
                        .task { [feedURL = state.feedURL] in
                            let result = await rssClient.fetch(feedURL)
                            return .rssShowResponse(result)
                        }
                        .cancellable(id: RSSRequestID.self)
                    ),
                    .run { send in
                        for await downloadStates in soundFileClient.downloadStatesPublisher.values {
                            await send(.downloadStatesResponse(downloadStates))
                        }
                    },
                    .run { send in
                        for await downloadError in soundFileClient.downloadErrorPublisher.values {
                            await send(.downloadErrorResponse(downloadError))
                        }
                    }
                )
            case .disappear:
                return .cancel(id: RSSRequestID.self)
            case .toggleFollowButtonTapped:
                guard let followed = state.followed else { return .none }

                let show = Show(
                    title: state.title,
                    description: state.description,
                    author: state.author,
                    feedURL: state.feedURL,
                    imageURL: state.imageURL,
                    linkURL: state.linkURL,
                    episodes: state.episodes
                )

                return .task {
                    .toggleFollowResponse(
                        followed
                        ? databaseClient.unfollowShow(show.feedURL).map { true }
                        : databaseClient.followShow(show).map { true }
                    )
                }
            case .copyFeedURLButtonTapped:
                return .fireAndForget { [feedURL = state.feedURL] in
                    clipboardClient.copy(feedURL.absoluteString)
                    messageClient.presentSuccess("Copied")
                }
            case .downloadEpisodeButtonTapped(let episode):
                return .fireAndForget { [downloadState = state.downloadState(id: episode.id)] in
                    switch downloadState {
                    case .notDownloaded:
                        try await soundFileClient.download(episode)
                    case .pushedToDownloadQueue:
                        break
                    case .downloading:
                        try await soundFileClient.cancelDownload(episode)
                    case .downloaded:
                        // FIXME: play sound
                        break
                    }
                }
            case .databaseShowResponse(let result):
                switch result {
                case .success(let show):
                    state.followed = show != nil
                    if let show {
                        reflectShow(state: &state, show: show)
                    }
                    return .none
                case .failure:
                    return .fireAndForget {
                        messageClient.presentError("Failed to communicate with database")
                    }
                }
            case .rssShowResponse(let result):
                state.taskRequestInFlight = false
                switch result {
                case .success(let show):
                    reflectShow(state: &state, show: show)
                    return .none
                case .failure(let error):
                    let message: String
                    switch error {
                    case .invalidFeed:
                        message = "Invalid rss feed"
                    case .networkError(reason: let error):
                        message = error.localizedDescription
                    }
                    return .fireAndForget {
                        messageClient.presentError(message)
                    }
                }
            case .toggleFollowResponse(let result):
                switch result {
                case .success:
                    state.followed?.toggle()
                    return .none
                case .failure:
                    return .fireAndForget { [followed = state.followed ?? false] in
                        let message = followed
                        ? "Failed to unfollow the show"
                        : "Failed to follow the show"
                        messageClient.presentError(message)
                    }
                }
            case .downloadStatesResponse(let downloadStates):
                state.downloadStates = downloadStates
                return .none
            case .downloadErrorResponse(let error):
                let message: String
                switch error {
                case .unexpectedError:
                    message = "Something went wrong"
                case .downloadError:
                    message = "Failed to download the episode"
                }
                return .fireAndForget {
                    messageClient.presentError(message)
                }
            }
        }
    }

    private func reflectShow(state: inout State, show: Show) {
        state.imageURL = show.imageURL
        state.title = show.title
        state.author = show.author
        state.linkURL = show.linkURL
        state.description = show.description
        state.episodes = show.episodes
    }
}
