import Foundation

protocol HasMessage {
    var message: String { get }
}

public enum ITunesError: Error, Equatable, HasMessage {
    case invalidQuery

    var message: String {
        switch self {
        case .invalidQuery:
            return "Query is invalid"
        }
    }
}

public enum RSSError: Error, Equatable, HasMessage {
    case fetchError
    case invalidFeed

    var message: String {
        switch self {
        case .invalidFeed:
            return "Something went wrong with this show"
        case .fetchError:
            return "Failed to fetch information about this show"
        }
    }
}

public enum DatabaseError: Error, Equatable, HasMessage {
    case followError
    case alreadyFollowed

    var message: String {
        switch self {
        case .followError:
            return "Failed to follow the show"
        case .alreadyFollowed:
            return "This show is already followed"
        }
    }
}
