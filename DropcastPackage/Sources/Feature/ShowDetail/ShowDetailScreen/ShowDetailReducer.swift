import ComposableArchitecture
import DatabaseClient
import Entity
import Foundation
import MessageClient
import RSSClient

struct ShowDetailReducer: ReducerProtocol {
    struct State: Equatable {
        var feedURL: URL
        var imageURL: URL
        var title: String
        var author: String?
        var description: String?
        var linkURL: URL?
        var followed: Bool? // initially undetermined

        var taskRequestInFlight: Bool = false
    }

    enum Action: Equatable {
        case task
        case toggleFollowButtonTapped

        case databaseShowResponse(TaskResult<Show?>)
        case rssShowResponse(TaskResult<Show>)
        case followResponse(TaskResult<Bool>)
    }

    @Dependency(\.databaseClient) private var databaseClient
    @Dependency(\.messageClient) private var messageClient
    @Dependency(\.rssClient) private var rssClient

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                state.taskRequestInFlight = true
                return .merge(
                    .task { [feedURL = state.feedURL] in
                        await .databaseShowResponse(
                            TaskResult {
                                try databaseClient.fetchShow(feedURL)
                            }
                        )
                    },
                    .task { [feedURL = state.feedURL] in
                        await .rssShowResponse(
                            TaskResult {
                                try await rssClient.fetch(feedURL)
                            }
                        )
                    }
                )
            case .toggleFollowButtonTapped:
                let show = Show(
                    title: state.title,
                    description: state.description,
                    author: state.author,
                    feedURL: state.feedURL,
                    imageURL: state.imageURL,
                    linkURL: state.linkURL,
                    episodes: []
                )
                return .task {
                    await .followResponse(
                        TaskResult {
                            try databaseClient.followShow(show)
                            return true
                        }
                    )
                }
            case .databaseShowResponse(let result):
                switch result {
                case .success(let show):
                    state.followed = show != nil
                    return .none
                case .failure(let error):
                    return .fireAndForget {
                        messageClient.presentError(error.userMessage)
                    }
                }
            case .rssShowResponse(let result):
                state.taskRequestInFlight = false
                switch result {
                case .success(let show):
                    state.imageURL = show.imageURL
                    state.title = show.title
                    state.author = show.author
                    state.linkURL = show.linkURL
                    state.description = show.description
                    return .none
                case .failure(let error):
                    return .fireAndForget {
                        messageClient.presentError(error.userMessage)
                    }
                }
            case .followResponse(let result):
                switch result {
                case .success:
                    state.followed = true
                    return .none
                case .failure(let error):
                    return .fireAndForget {
                        messageClient.presentError(error.userMessage)
                    }
                }
            }
        }
    }
}
