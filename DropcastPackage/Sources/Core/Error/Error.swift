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
            return L10n.offline
        case .timeout:
            return L10n.timeout
        case .cancelled:
            return L10n.cancelled
        case .serverError(let status):
            switch status {
            case 400..<500:
                return L10n.invalidRequest
            default:
                return L10n.serverError
            }
        case .unknownError:
            return L10n.somethingWentWrong
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
