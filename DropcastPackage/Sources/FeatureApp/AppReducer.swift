import ComposableArchitecture
import FeatureFeed
import FeatureShows

extension AppReducer {
    enum Tab {
        case feed
        case shows
    }
}

struct AppReducer: ReducerProtocol {
    struct State: Equatable {
        var activeTab: Tab = .feed

        var feedState: FeedReducer.State = .init()
        var showsState: ShowsReducer.State = .init()
    }

    enum Action: Equatable {
        case activeTabChanged(Tab)

        case feed(FeedReducer.Action)
        case shows(ShowsReducer.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .activeTabChanged(let tab):
                state.activeTab = tab
                return .none
            case .feed:
                return .none
            case .shows:
                return .none
            }
        }

        Scope(state: \.feedState, action: /Action.feed) {
            FeedReducer()
        }

        Scope(state: \.showsState, action: /Action.shows) {
            ShowsReducer()
        }
    }
}
