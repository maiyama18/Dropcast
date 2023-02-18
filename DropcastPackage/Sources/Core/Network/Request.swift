import Error
import Foundation

public func request(session: URLSession, url: URL) async -> Result<Data, NetworkError> {
    do {
        let (data, response) = try await session.data(from: url)
        guard let response = response as? HTTPURLResponse else {
            return .failure(.unknownError)
        }
        
        switch response.statusCode {
        case 200..<300:
            return .success(data)
        default:
            return .failure(.serverError(status: response.statusCode))
        }
    } catch {
        let nsError = error as NSError
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet:
            return .failure(.offline)
        case NSURLErrorTimedOut:
            return .failure(.timeout)
        case NSURLErrorCancelled:
            return .failure(.cancelled)
        default:
            return .failure(.unknownError)
        }
    }
}
