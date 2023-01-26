import ComposableArchitecture
import Entity
import ITunesClient
import MessageClient

public struct FollowShowsReducer: ReducerProtocol, Sendable {
    public struct State: Equatable {
        public enum ShowsState: Equatable {
            case prompt
            case empty
            case loaded(shows: [Show])

            var currentShows: [Show] {
                switch self {
                case .prompt, .empty:
                    return []
                case .loaded(let shows):
                    return shows
                }
            }
        }

        public var query: String = ""
        public var showsState: ShowsState = .prompt
        public var searchRequestInFlight: Bool = false
    }

    public enum Action: Equatable {
        case queryChanged(query: String)
        case queryChangeDebounced

        case searchResponse(TaskResult<[Show]>)
    }

    @Dependency(\.iTunesClient) private var iTunesClient
    @Dependency(\.messageClient) private var messageClient

    private enum SearchID {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .queryChanged(let query):
                state.query = query

                if query.isEmpty {
                    state.searchRequestInFlight = false
                    state.showsState = .prompt
                    return .cancel(id: SearchID.self)
                } else {
                    return .none
                }
            case .queryChangeDebounced:
                let query = state.query
                guard !query.isEmpty else {
                    return .none
                }

                state.searchRequestInFlight = true
                return .task {
                    await .searchResponse(
                        TaskResult {
                            try await self.iTunesClient.searchShows(query)
                        }
                    )
                }
                .cancellable(id: SearchID.self)
            case .searchResponse(let result):
                state.searchRequestInFlight = false

                switch result {
                case .success(let shows):
                    state.showsState = shows.isEmpty ? .empty : .loaded(shows: shows)
                    return .none
                case .failure(let error):
                    let currentShows = state.showsState.currentShows
                    state.showsState = currentShows.isEmpty ? .prompt : .loaded(shows: currentShows)
                    return .fireAndForget {
                        messageClient.presentError(error.userMessage)
                    }
                }
            }
        }
    }
}
