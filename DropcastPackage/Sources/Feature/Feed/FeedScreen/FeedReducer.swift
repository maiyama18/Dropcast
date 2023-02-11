import ComposableArchitecture
import Entity
import SoundFileClient

public struct FeedReducer: ReducerProtocol, Sendable {
    public struct State: Equatable {
        public var episodes: IdentifiedArrayOf<Episode>?

        public init() {}
    }

    public enum Action: Equatable, Sendable {
        case task
        case followShowsButtonTapped
        case downloadEpisodeButtonTapped(episode: Episode)

        case episodesResponse(IdentifiedArrayOf<Episode>)
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
                return .run { send in
                    for await episodes in databaseClient.followedEpisodesStream() {
                        await send(.episodesResponse(episodes))
                    }
                }
            case .followShowsButtonTapped:
                // handled by parent reducer
                return .none
            case .downloadEpisodeButtonTapped(let episode):
                return .fireAndForget {
                    try await soundFileClient.download(episode)
                }
                .cancellable(id: AnyHashable(DownloadID(guid: episode.guid)))
            case .episodesResponse(let episodes):
                state.episodes = episodes
                return .none
            }
        }
    }
}
