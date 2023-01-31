import ComposableArchitecture
import Entity
import Error
import Foundation
import ITunesClient
import MessageClient
import RSSClient

public struct FollowShowsReducer: ReducerProtocol, Sendable {
    public struct State: Equatable {
        public struct Show: Equatable, Identifiable {
            public var feedURL: URL
            public var imageURL: URL
            public var title: String
            public var author: String?

            public var id: URL { feedURL }

            public init(feedURL: URL, imageURL: URL, title: String, author: String?) {
                self.feedURL = feedURL
                self.imageURL = imageURL
                self.title = title
                self.author = author
            }

            init(iTunesShow: ITunesShow) {
                self.init(feedURL: iTunesShow.feedURL, imageURL: iTunesShow.artworkLowQualityURL, title: iTunesShow.showName, author: iTunesShow.artistName)
            }

            init(show: Entity.Show) {
                self.init(feedURL: show.feedURL, imageURL: show.imageURL, title: show.title, author: show.author)
            }
        }

        public enum ShowsState: Equatable {
            case prompt
            case empty
            case loaded(shows: [State.Show])

            var currentShows: [State.Show] {
                switch self {
                case .prompt, .empty:
                    return []
                case .loaded(let shows):
                    return shows
                }
            }
        }

        public var query: String = ""
        public var showsState: ShowsState = .prompt
        public var searchRequestInFlight: Bool = false
    }

    public enum Action: Equatable {
        case queryChanged(query: String)
        case queryChangeDebounced

        case querySearchResponse(TaskResult<[ITunesShow]>)
        case urlSearchResponse(TaskResult<Entity.Show>)
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
                    if let url = URL(string: query), (url.scheme == "https" || url.scheme == "http") {
                        return await .urlSearchResponse(TaskResult { try await rssClient.fetch(url) })
                    } else {
                        return await .querySearchResponse(TaskResult { try await self.iTunesClient.searchShows(query) })
                    }
                }
                .cancellable(id: SearchID.self)
            case .querySearchResponse(let result):
                state.searchRequestInFlight = false

                switch result {
                case .success(let shows):
                    state.showsState = shows.isEmpty ? .empty : .loaded(shows: shows.map { State.Show(iTunesShow: $0) })
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
                    state.showsState = .loaded(shows: [State.Show(show: show)])
                    return .none
                case .failure:
                    state.showsState = .empty
                    return .none
                }
            }
        }
    }
}
