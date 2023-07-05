import Combine
import DatabaseClient
import Dependencies
import Entity
import Extension
import Foundation
import IdentifiedCollections
import MessageClient

@MainActor
public final class ShowListViewModel: ObservableObject {
    enum Action {
        case tapAddButton
        case tapShowRow(show: Show)
        case swipeToDeleteShow(feedURL: URL)
    }

    enum Event {
        case presentShowSearch
        case pushShowDetail(show: Show)
    }

    @Published var path: [ShowListRoute] = []
    @Published var showSearchPresented: Bool = false
    @Published private(set) var shows: IdentifiedArrayOf<Show>?

    @Dependency(\.databaseClient) private var databaseClient
    @Dependency(\.messageClient) private var messageClient

    public init() {
        subscribe()
    }

    func handle(action: Action) async {
        switch action {
        case .tapAddButton:
            showSearchPresented = true
        case .tapShowRow(let show):
            path.append(
                .showDetail(
                    args: .init(
                        showsEpisodeActionButtons: true,
                        feedURL: show.feedURL,
                        imageURL: show.imageURL,
                        title: show.title,
                        episodes: show.episodes,
                        author: show.author,
                        description: show.description,
                        linkURL: show.linkURL,
                        followed: true
                    )
                )
            )
        case .swipeToDeleteShow(let feedURL):
            do {
                try databaseClient.unfollowShow(feedURL).get()
            } catch {
                messageClient.presentError(L10n.Error.failedToUnfollow)
            }
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
