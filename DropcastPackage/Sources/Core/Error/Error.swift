import Foundation

protocol HasMessage {
    var message: String { get }
}

public enum NetworkError: LocalizedError, Equatable {
    case offline
    case timeout
    case cancelled
    case serverError(status: Int)
    case unknownError
    
    public var errorDescription: String? {
        switch self {
        case .offline:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .cancelled:
            return "Request cancelled"
        case .serverError(let status):
            switch status {
            case 400..<500:
                return "Invalid request"
            default:
                return "Service returns error"
            }
        case .unknownError:
            return "Something went wrong"
        }
    }
}

public enum ITunesError: Error, Equatable {
    case invalidQuery
    case parseError
    case networkError(reason: NetworkError)
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
