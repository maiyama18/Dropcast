import ComposableArchitecture
import Entity
import Foundation
import MessageClient
import ShowDetailFeature

public struct ShowListReducer: ReducerProtocol, Sendable {
    public struct State: Equatable {
        public var shows: IdentifiedArrayOf<Show>?
        public var showSearchState: ShowSearchReducer.State?
        public var selectedShowState: Identified<URL, ShowDetailReducer.State>?

        public init() {}

        public var showSearchPresented: Bool { showSearchState != nil }
    }

    public enum Action: Equatable, Sendable {
        case task
        case openShowSearchButtonTapped
        case showSwipeToDeleted(feedURL: URL)
        case showSearchDismissed
        case showDetailSelected(feedURL: URL?)

        case showsResponse(IdentifiedArrayOf<Show>)

        case showSearch(ShowSearchReducer.Action)
        case showDetail(ShowDetailReducer.Action)
    }

    @Dependency(\.databaseClient) private var databaseClient
    @Dependency(\.messageClient) private var messageClient

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
            case .showSwipeToDeleted(let feedURL):
                return .fireAndForget {
                    do {
                        try databaseClient.unfollowShow(feedURL).get()
                    } catch {
                        messageClient.presentError("Failed to unfollow the show")
                    }
                }
            case .showSearchDismissed:
                state.showSearchState = nil
                return .none
            case .showDetailSelected(let feedURL):
                if let feedURL, let show = state.shows?[id: feedURL] {
                    state.selectedShowState = Identified(
                        .init(
                            feedURL: show.feedURL,
                            imageURL: show.imageURL,
                            title: show.title,
                            episodes: show.episodes,
                            author: show.author,
                            description: show.description,
                            linkURL: show.linkURL
                        ),
                        id: \.feedURL
                    )
                } else {
                    state.selectedShowState = nil
                }
                return .none
            case .showsResponse(let shows):
                state.shows = shows
                return .none
            case .showSearch:
                return .none
            case .showDetail:
                return .none
            }
        }
        .ifLet(\.showSearchState, action: /Action.showSearch) {
            ShowSearchReducer()
        }
        .ifLet(\.selectedShowState, action: /Action.showDetail) {
            Scope(state: \Identified<URL, ShowDetailReducer.State>.value, action: /.self) {
                ShowDetailReducer()
            }
        }
    }
}
