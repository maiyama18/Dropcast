import DatabaseClient
import Dependencies
import Entity
import Extension
import Foundation
import IdentifiedCollections
import MessageClient
import Observation

@MainActor
@Observable
public final class ShowListViewModel {
    enum Action {
        case tapAddButton
        case tapShowRow(show: Show)
        case swipeToDeleteShow(feedURL: URL)
    }

    var path: [ShowListRoute] = []
    var showSearchPresented: Bool = false
    private(set) var shows: IdentifiedArrayOf<Show>?

    @ObservationIgnored @Dependency(\.databaseClient) private var databaseClient
    @ObservationIgnored @Dependency(\.messageClient) private var messageClient

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
                messageClient.presentError(String(localized: "Failed to unfollow the show", bundle: .module))
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
