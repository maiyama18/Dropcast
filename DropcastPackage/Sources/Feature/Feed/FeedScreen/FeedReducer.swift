import ComposableArchitecture
import Entity
import SoundFileClient

public struct FeedReducer: ReducerProtocol, Sendable {
    public struct State: Equatable {
        public var episodes: IdentifiedArrayOf<Episode>?
        var downloadStates: [String: EpisodeDownloadState]?
        
        public func downloadState(guid: String) -> EpisodeDownloadState {
            guard let downloadStates else { return .notDownloaded }
            return downloadStates[guid] ?? .notDownloaded
        }

        public init() {}
    }

    public enum Action: Equatable, Sendable {
        case task
        case followShowsButtonTapped
        case downloadEpisodeButtonTapped(episode: Episode)

        case episodesResponse(IdentifiedArrayOf<Episode>)
        case downloadStatesResponse([String: EpisodeDownloadState])
    }

    @Dependency(\.databaseClient) private var databaseClient
    @Dependency(\.soundFileClient) private var soundFileClient

    public init() {}
    
    private struct DownloadID: Hashable {
        var guid: String
    }

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
                    }
                )
            case .followShowsButtonTapped:
                // handled by parent reducer
                return .none
            case .downloadEpisodeButtonTapped(let episode):
                return .fireAndForget {
                    try await soundFileClient.download(episode)
                }
                .cancellable(id: AnyHashable(DownloadID(guid: episode.guid)))
            case .downloadStatesResponse(let downloadStates):
                state.downloadStates = downloadStates
                return .none
            case .episodesResponse(let episodes):
                state.episodes = episodes
                return .none
            }
        }
    }
}
