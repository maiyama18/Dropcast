import ComposableArchitecture

public struct ShowsReducer: ReducerProtocol {
    public struct State: Equatable {
        public var followShowsState: FollowShowsReducer.State?

        public init() {}

        public var followShowsPresented: Bool { followShowsState != nil }
    }

    public enum Action: Equatable {
        case task
        case openFollowShowsButtonTapped
        case followShowsDismissed

        case followShows(FollowShowsReducer.Action)
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                return .none
            case .openFollowShowsButtonTapped:
                state.followShowsState = FollowShowsReducer.State()
                return .none
            case .followShowsDismissed:
                state.followShowsState = nil
                return .none
            case .followShows:
                return .none
            }
        }
        .ifLet(\.followShowsState, action: /Action.followShows) {
            FollowShowsReducer()
        }
    }
}
