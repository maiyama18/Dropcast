import ClipboardClient
import ComposableArchitecture
import DatabaseClient
import Entity
import Foundation
import MessageClient
import RSSClient

public struct ShowDetailReducer: ReducerProtocol, Sendable {
    public struct State: Equatable {
        public var feedURL: URL
        public var imageURL: URL
        public var title: String
        public var author: String?
        public var description: String?
        public var linkURL: URL?
        public var followed: Bool? // initially undetermined

        public var taskRequestInFlight: Bool = false

        public init(
            feedURL: URL,
            imageURL: URL,
            title: String,
            author: String? = nil,
            description: String? = nil,
            linkURL: URL? = nil,
            followed: Bool? = nil,
            taskRequestInFlight: Bool = false
        ) {
            self.feedURL = feedURL
            self.imageURL = imageURL
            self.title = title
            self.author = author
            self.description = description
            self.linkURL = linkURL
            self.followed = followed
            self.taskRequestInFlight = taskRequestInFlight
        }
    }

    public enum Action: Equatable, Sendable {
        case task
        case disappear
        case toggleFollowButtonTapped
        case copyFeedURLButtonTapped

        case databaseShowResponse(TaskResult<Show?>)
        case rssShowResponse(TaskResult<Show>)
        case toggleFollowResponse(TaskResult<Bool>)
    }

    @Dependency(\.clipboardClient) private var clipboardClient
    @Dependency(\.databaseClient) private var databaseClient
    @Dependency(\.messageClient) private var messageClient
    @Dependency(\.rssClient) private var rssClient

    public init() {}

    private enum RSSRequestID {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                state.taskRequestInFlight = true
                return .concatenate(
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
                    .cancellable(id: RSSRequestID.self)
                )
            case .disappear:
                return .cancel(id: RSSRequestID.self)
            case .toggleFollowButtonTapped:
                guard let followed = state.followed else { return .none }

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
                    await .toggleFollowResponse(
                        TaskResult {
                            if followed {
                                try databaseClient.unfollowShow(show.feedURL)
                            } else {
                                try databaseClient.followShow(show)
                            }
                            return true
                        }
                    )
                }
            case .copyFeedURLButtonTapped:
                return .fireAndForget { [feedURL = state.feedURL] in
                    clipboardClient.copy(feedURL.absoluteString)
                    messageClient.presentSuccess("Copied")
                }
            case .databaseShowResponse(let result):
                switch result {
                case .success(let show):
                    state.followed = show != nil
                    if let show {
                        reflectShow(state: &state, show: show)
                    }
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
                    reflectShow(state: &state, show: show)
                    return .none
                case .failure(let error):
                    return .fireAndForget {
                        messageClient.presentError(error.userMessage)
                    }
                }
            case .toggleFollowResponse(let result):
                switch result {
                case .success:
                    state.followed?.toggle()
                    return .none
                case .failure(let error):
                    return .fireAndForget {
                        messageClient.presentError(error.userMessage)
                    }
                }
            }
        }
    }

    private func reflectShow(state: inout State, show: Show) {
        state.imageURL = show.imageURL
        state.title = show.title
        state.author = show.author
        state.linkURL = show.linkURL
        state.description = show.description
    }
}
