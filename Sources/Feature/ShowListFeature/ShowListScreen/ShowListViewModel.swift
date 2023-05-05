import Combine
import Dependencies
import Entity
import Extension
import Foundation
import IdentifiedCollections

@MainActor
public final class ShowListViewModel: ObservableObject {
    enum Action {
        case tapAddButton
        case tapShowRow
        case swipeToDeleteShow(feedURL: URL)
    }
    
    enum Event {
        case presentShowSearch
    }
    
    @Published private(set) var shows: IdentifiedArrayOf<Show>?
    
    @Dependency(\.databaseClient) private var databaseClient
    @Dependency(\.messageClient) private var messageClient
    
    var eventStream: AsyncStream<Event> { eventSubject.eraseToStream() }
    private let eventSubject: PassthroughSubject<Event, Never> = .init()
    
    public init() {
        subscribe()
    }
    
    func handle(action: Action) async {
        switch action {
        case .tapAddButton:
            eventSubject.send(.presentShowSearch)
        case .tapShowRow:
            print("TODO")
        case .swipeToDeleteShow(let feedURL):
            print("TODO")
        }
    }
    
    private func subscribe() {
        Task { [weak self, databaseClient] in
            for await shows in databaseClient.followedShowsStream() {
                self?.shows = shows
            }
        }
    }
}
