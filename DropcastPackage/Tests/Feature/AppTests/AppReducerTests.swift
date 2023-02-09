import ComposableArchitecture
import XCTest

@testable import AppFeature

final class AppReducerTests: XCTestCase {
    func test_activeTabChanged() {
        let store = TestStore(initialState: AppReducer.State(), reducer: AppReducer())

        store.send(.activeTabChanged(.shows)) {
            $0.activeTab = .shows
        }
        store.send(.activeTabChanged(.feed)) {
            $0.activeTab = .feed
        }
    }
}
