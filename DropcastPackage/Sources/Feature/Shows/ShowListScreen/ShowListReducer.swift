import ComposableArchitecture
import Entity

public struct ShowListReducer: ReducerProtocol, Sendable {
    public struct State: Equatable {
        public var shows: IdentifiedArrayOf<SimpleShow>?
        public var showSearchState: ShowSearchReducer.State?

        public init() {}

        public var followShowsPresented: Bool { showSearchState != nil }
    }

    public enum Action: Equatable, Sendable {
        case task
        case openShowSearchButtonTapped
        case showSearchDismissed

        case showsResponse(IdentifiedArrayOf<Show>)

        case showSearch(ShowSearchReducer.Action)
    }

    @Dependency(\.databaseClient) private var databaseClient

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                return .run { send in
                    for await shows in databaseClient.followedShowsStream() {
                        await send(.showsResponse(shows))
                    }
                }
            case .openShowSearchButtonTapped:
                state.showSearchState = ShowSearchReducer.State()
                return .none
            case .showSearchDismissed:
                state.showSearchState = nil
                return .none
            case .showsResponse(let shows):
                state.shows = IdentifiedArrayOf(uniqueElements: shows.map { SimpleShow(show: $0) })
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
