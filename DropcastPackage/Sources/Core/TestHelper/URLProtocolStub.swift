import Dependencies
import Foundation

public final class URLProtocolStub: URLProtocol {
    public static let responses: LockIsolated<[URL: Result<Data, Error>]> = .init([:])

    public static func setResponses(_ responses: [URL: Result<Data, Error>]) {
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
              let result = Self.responses.value[url] else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "stub response not match", code: 0))
            return
        }

        switch result {
        case .success(let data):
            let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
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
