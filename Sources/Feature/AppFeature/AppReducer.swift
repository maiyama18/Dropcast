import ComposableArchitecture
import FeedFeature
import SettingsFeature
import ShowsFeature

extension AppReducer {
    enum Tab {
        case feed
        case shows
        case settings
    }
}

struct AppReducer: ReducerProtocol {
    struct State: Equatable {
        var activeTab: Tab = .feed

        var feedState: FeedReducer.State = .init()
        var showsState: ShowListReducer.State = .init()
        var settingsState: SettingsReducer.State = .init()
    }

    enum Action: Equatable {
        case activeTabChanged(Tab)

        case feed(FeedReducer.Action)
        case shows(ShowListReducer.Action)
        case settings(SettingsReducer.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .activeTabChanged(let tab):
                state.activeTab = tab
                return .none
            case .feed(let feedAction):
                switch feedAction {
                case .followShowsButtonTapped:
                    state.activeTab = .shows
                    state.showsState.showSearchState = .init()
                    return .none
                default:
                    return .none
                }
            case .shows:
                return .none
            case .settings:
                return .none
            }
        }

        Scope(state: \.feedState, action: /Action.feed) {
            FeedReducer()
        }

        Scope(state: \.showsState, action: /Action.shows) {
            ShowListReducer()
        }
        
        Scope(state: \.settingsState, action: /Action.settings) {
            SettingsReducer()
        }
    }
}
