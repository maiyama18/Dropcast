import Foundation

protocol HasMessage {
    var message: String { get }
}

public enum ITunesError: Error, HasMessage {
    case invalidQuery

    var message: String {
        switch self {
        case .invalidQuery:
            return "Query is invalid"
        }
    }
}

public enum RSSError: Error, HasMessage {
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

public enum DatabaseError: Error, HasMessage {
    case followError

    var message: String {
        switch self {
        case .followError:
            return "Failed to follow the show"
        }
    }
}
