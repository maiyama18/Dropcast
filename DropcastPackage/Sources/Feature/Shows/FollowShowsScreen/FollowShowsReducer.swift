import ComposableArchitecture

public struct FollowShowsReducer: ReducerProtocol {
    public struct State: Equatable {
        var query: String = ""
    }

    public enum Action: Equatable {
        case queryChanged(query: String)
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .queryChanged(let query):
                state.query = query
                return .none
            }
        }
    }
}
