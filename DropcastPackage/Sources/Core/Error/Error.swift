import Foundation

protocol HasMessage {
    var message: String { get }
}

public enum NetworkError: Error, Equatable, HasMessage {
    case offline
    case timeout
    case cancelled
    case serverError(status: Int)
    case unknownError
    
    var message: String {
        ""
    }
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

public enum DatabaseError: Error, Equatable {
    case databaseError
}

public enum SoundFileClientError: Error, Equatable, HasMessage {
    case unexpectedError
    case downloadError

    var message: String {
        switch self {
        case .unexpectedError:
            return "Unexpected error occurred"
        case .downloadError:
            return "Failed to download the episode"
        }
    }
}
