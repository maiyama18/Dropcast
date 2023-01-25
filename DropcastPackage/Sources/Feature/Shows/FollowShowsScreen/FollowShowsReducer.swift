import ComposableArchitecture
import Entity
import ITunesClient

public struct FollowShowsReducer: ReducerProtocol, Sendable {
    public struct State: Equatable {
        public var query: String = ""
        public var shows: [Show] = []
    }

    public enum Action: Equatable {
        case queryChanged(query: String)
        case queryChangeDebounced

        case searchResponse(TaskResult<[Show]>)
    }

    @Dependency(\.iTunesClient) private var iTunesClient

    private enum SearchID {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .queryChanged(let query):
                state.query = query

                if query.isEmpty {
                    state.shows = []
                    return .cancel(id: SearchID.self)
                } else {
                    return .none
                }
            case .queryChangeDebounced:
                let query = state.query
                guard !query.isEmpty else {
                    return .none
                }

                return .task {
                    await .searchResponse(
                        TaskResult {
                            try await self.iTunesClient.searchShows(query)
                        }
                    )
                }
                .cancellable(id: SearchID.self)
            case .searchResponse(let result):
                switch result {
                case .success(let shows):
                    state.shows = shows
                    return .none
                case .failure(let error):

                    // TODO: エラーメッセージを表示
                    print(error)

                    return .none
                }
            }
        }
    }
}
