import ComposableArchitecture
import Entity
import Error
import Foundation
import ITunesClient
import MessageClient
import RSSClient
import ShowDetailFeature

public struct ShowSearchReducer: ReducerProtocol, Sendable {
    public struct State: Equatable {
        public enum ShowsState: Equatable {
            case prompt
            case empty
            case loaded(shows: IdentifiedArrayOf<SimpleShow>)

            var currentShows: IdentifiedArrayOf<SimpleShow> {
                switch self {
                case .prompt, .empty:
                    return []
                case .loaded(let shows):
                    return shows
                }
            }
        }

        public init() {}

        public var query: String = ""
        public var showsState: ShowsState = .prompt
        public var searchRequestInFlight: Bool = false

        public var selectedShowState: Identified<URL, ShowDetailReducer.State>?
    }

    public enum Action: Equatable, Sendable {
        case queryChanged(query: String)
        case queryChangeDebounced
        case showDetailSelected(feedURL: URL?)

        case querySearchResponse(TaskResult<[ITunesShow]>)
        case urlSearchResponse(TaskResult<Entity.Show>)

        case showDetail(ShowDetailReducer.Action)
    }

    @Dependency(\.iTunesClient) private var iTunesClient
    @Dependency(\.messageClient) private var messageClient
    @Dependency(\.rssClient) private var rssClient

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
                    if let url = URL(string: query), url.scheme == "https" {
                        return await .urlSearchResponse(TaskResult { try await rssClient.fetch(url) })
                    } else {
                        return await .querySearchResponse(TaskResult { try await self.iTunesClient.searchShows(query) })
                    }
                }
                .cancellable(id: SearchID.self)
            case .showDetailSelected(let feedURL):
                if let feedURL, let show = state.showsState.currentShows[id: feedURL] {
                    state.selectedShowState = Identified(
                        .init(feedURL: show.feedURL, imageURL: show.imageURL, title: show.title, episodes: [], author: show.author),
                        id: \.feedURL
                    )
                } else {
                    state.selectedShowState = nil
                }
                return .none
            case .querySearchResponse(let result):
                state.searchRequestInFlight = false

                switch result {
                case .success(let shows):
                    state.showsState = shows.isEmpty
                    ? .empty
                    : .loaded(
                        shows: IdentifiedArrayOf(
                            uniqueElements: shows
                                .uniqued(on: { $0.feedURL })
                                .map { SimpleShow(iTunesShow: $0) }
                        )
                    )
                    return .none
                case .failure(let error):
                    let currentShows = state.showsState.currentShows
                    state.showsState = currentShows.isEmpty ? .prompt : .loaded(shows: currentShows)
                    return .fireAndForget {
                        messageClient.presentError(error.userMessage)
                    }
                }
            case .urlSearchResponse(let result):
                state.searchRequestInFlight = false

                switch result {
                case .success(let show):
                    state.showsState = .loaded(shows: [SimpleShow(show: show)])
                    return .none
                case .failure:
                    state.showsState = .empty
                    return .none
                }
            case .showDetail:
                return .none
            }
        }
        .ifLet(\.selectedShowState, action: /Action.showDetail) {
            Scope(state: \Identified<URL, ShowDetailReducer.State>.value, action: /.self) {
                ShowDetailReducer()
            }
        }
    }
}
