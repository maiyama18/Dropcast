import ComposableArchitecture

public struct FeedReducer: ReducerProtocol {
    public struct State: Equatable {
        public init() {}
    }

    public enum Action: Equatable {
        case task
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .task:
                return .none
            }
        }
    }
}
