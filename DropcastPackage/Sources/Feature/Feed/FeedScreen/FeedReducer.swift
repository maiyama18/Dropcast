import ComposableArchitecture
import Entity
import Error
import MessageClient
import SoundFileClient

public struct FeedReducer: ReducerProtocol, Sendable {
    public struct State: Equatable {
        public var episodes: IdentifiedArrayOf<Episode>?
        var downloadStates: [Episode.ID: EpisodeDownloadState]?

        public func downloadState(id: Episode.ID) -> EpisodeDownloadState {
            guard let downloadStates else { return .notDownloaded }
            return downloadStates[id] ?? .notDownloaded
        }

        public init() {}
    }

    public enum Action: Equatable, Sendable {
        case task
        case followShowsButtonTapped
        case downloadEpisodeButtonTapped(episode: Episode)

        case episodesResponse(IdentifiedArrayOf<Episode>)
        case downloadStatesResponse([String: EpisodeDownloadState])
        case downloadErrorResponse(SoundFileClientError)
    }

    @Dependency(\.databaseClient) private var databaseClient
    @Dependency(\.messageClient) private var messageClient
    @Dependency(\.soundFileClient) private var soundFileClient

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                return .merge(
                    .run { send in
                        for await episodes in databaseClient.followedEpisodesStream() {
                            await send(.episodesResponse(episodes))
                        }
                    },
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
            case .followShowsButtonTapped:
                // handled by parent reducer
                return .none
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
            case .downloadStatesResponse(let downloadStates):
                state.downloadStates = downloadStates
                return .none
            case .downloadErrorResponse(let error):
                let message: String
                switch error {
                case .unexpectedError:
                    message = L10n.Error.somethingWentWrong
                case .downloadError:
                    message = L10n.Error.downloadError
                }
                return .fireAndForget {
                    messageClient.presentError(message)
                }
            case .episodesResponse(let episodes):
                state.episodes = episodes
                return .none
            }
        }
    }
}
