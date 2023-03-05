import ComposableArchitecture

public struct SettingsReducer: ReducerProtocol {
    public struct State: Equatable {
        public var destination: Destination?

        public init() {}
    }

    public enum Destination: Equatable {
        case licenses(LicensesReducer.State)

        public enum Tag: Int {
            case licenses
        }

        var tag: Tag {
            switch self {
            case .licenses:
                return .licenses
            }
        }
    }

    public enum Action: Equatable {
        case destinationSet(tag: Destination.Tag?)

        case destination(DestinationAction)
    }

    public enum DestinationAction: Equatable {
        case licenses(LicensesReducer.Action)
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .destinationSet(let tag):
                switch tag {
                case .licenses:
                    state.destination = .licenses(.init())
                    return .none
                case nil:
                    state.destination = nil
                    return .none
                }
            case .destination:
                return .none
            }
        }
        .ifLet(\.destination, action: /Action.destination) {
            Scope(state: /Destination.licenses, action: /DestinationAction.licenses) {
                LicensesReducer()
            }
        }
    }

    public init() {}
}
