import ComposableArchitecture
import Entity

public struct FeedReducer: ReducerProtocol, Sendable {
    public struct State: Equatable {
        public var episodes: IdentifiedArrayOf<Episode>?

        public init() {}
    }

    public enum Action: Equatable, Sendable {
        case task
        case followShowsButtonTapped

        case episodesResponse(IdentifiedArrayOf<Episode>)
    }

    @Dependency(\.databaseClient) private var databaseClient

    public init() {}

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
                return .none
            case .episodesResponse(let episodes):
                state.episodes = episodes
                return .none
            }
        }
    }
}
