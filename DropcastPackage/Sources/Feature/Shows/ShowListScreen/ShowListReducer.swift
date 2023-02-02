import ComposableArchitecture

public struct ShowListReducer: ReducerProtocol {
    public struct State: Equatable {
        public var showSearchState: ShowSearchReducer.State?

        public init() {}

        public var followShowsPresented: Bool { showSearchState != nil }
    }

    public enum Action: Equatable {
        case task
        case openShowSearchButtonTapped
        case showSearchDismissed

        case showSearch(ShowSearchReducer.Action)
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                return .none
            case .openShowSearchButtonTapped:
                state.showSearchState = ShowSearchReducer.State()
                return .none
            case .showSearchDismissed:
                state.showSearchState = nil
                return .none
            case .showSearch:
                return .none
            }
        }
        .ifLet(\.showSearchState, action: /Action.showSearch) {
            ShowSearchReducer()
        }
    }
}
