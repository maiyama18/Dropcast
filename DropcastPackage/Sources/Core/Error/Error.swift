import Foundation

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

public enum RSSError: Error, Equatable {
    case invalidFeed
    case networkError(reason: NetworkError)
}

public enum DatabaseError: Error, Equatable {
    case databaseError
}

public enum SoundFileClientError: Error, Equatable {
    case unexpectedError
    case downloadError
}
