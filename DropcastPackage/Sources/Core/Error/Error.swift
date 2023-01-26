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
