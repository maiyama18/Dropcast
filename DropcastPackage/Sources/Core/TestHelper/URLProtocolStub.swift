import Dependencies
import Foundation

public struct StubResponse: Sendable {
    public let statusCode: Int
    public let result: Result<Data, Error>
    
    public init(statusCode: Int, result: Result<Data, Error>) {
        self.statusCode = statusCode
        self.result = result
    }
}

public final class URLProtocolStub: URLProtocol {
    public static let responses: LockIsolated<[URL: StubResponse]> = .init([:])

    public static func setResponses(_ responses: [URL: StubResponse]) {
        self.responses.withValue { $0 = responses }
    }

    override public class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override public func startLoading() {
        defer { client?.urlProtocolDidFinishLoading(self) }

        guard let url = request.url,
              let response = Self.responses.value[url] else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "stub response not match", code: 0))
            return
        }

        switch response.result {
        case .success(let data):
            let response = HTTPURLResponse(
                url: url,
                statusCode: response.statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
        case .failure(let error):
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override public func stopLoading() {}
}
