import ComposableArchitecture
import XCTest

@testable import AppFeature

final class AppReducerTests: XCTestCase {
    func test_active_tab_changed() {
        let store = TestStore(initialState: AppReducer.State(), reducer: AppReducer())

        store.send(.activeTabChanged(.shows)) {
            $0.activeTab = .shows
        }
        store.send(.activeTabChanged(.feed)) {
            $0.activeTab = .feed
        }
    }

    func test_tap_of_follow_shows_button_on_feed_tab_open_show_search() {
        let store = TestStore(initialState: AppReducer.State(), reducer: AppReducer())

        store.send(.feed(.followShowsButtonTapped)) {
            $0.activeTab = .shows
            $0.showsState.showSearchState = .init()
        }
    }
}
