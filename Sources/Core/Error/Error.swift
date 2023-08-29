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
            return String(localized: "No internet connection", bundle: .module)
        case .timeout:
            return String(localized: "Request timed out", bundle: .module)
        case .cancelled:
            return String(localized: "Request cancelled", bundle: .module)
        case .serverError(let status):
            switch status {
            case 400..<500:
                return String(localized: "Invalid request", bundle: .module)
            default:
                return String(localized: "Server returns error", bundle: .module)
            }
        case .unknownError:
            return String(localized: "Something went wrong", bundle: .module)
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
    case showNotFollowed
}
