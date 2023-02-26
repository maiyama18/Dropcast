import TestHelper
import XCTest

@testable import Network

final class NetworkTests: XCTestCase {
    func test() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        let urlSession = URLSession(configuration: config)

        URLProtocolStub.setResponses(
            [
                URL(string: "https://example.com/success")!: .init(
                    statusCode: 200,
                    result: .success("response".data(using: .utf8)!)
                ),
                URL(string: "https://example.com/500")!: .init(
                    statusCode: 500,
                    result: .success("response".data(using: .utf8)!)
                ),
                URL(string: "https://example.com/offline")!: .init(
                    statusCode: -1,
                    result: .failure(NSError(domain: "", code: NSURLErrorNotConnectedToInternet))
                ),
                URL(string: "https://example.com/timeout")!: .init(
                    statusCode: -1,
                    result: .failure(NSError(domain: "", code: NSURLErrorTimedOut))
                ),
                URL(string: "https://example.com/cancelled")!: .init(
                    statusCode: -1,
                    result: .failure(NSError(domain: "", code: NSURLErrorCancelled))
                ),
                URL(string: "https://example.com/other")!: .init(
                    statusCode: -1,
                    result: .failure(NSError(domain: "", code: NSURLErrorCannotFindHost))
                ),
            ]
        )

        try await XCTAsyncAssertEqual(
            await request(session: urlSession, url: URL(string: "https://example.com/success")!),
            .success("response".data(using: .utf8)!)
        )

        try await XCTAsyncAssertEqual(
            await request(session: urlSession, url: URL(string: "https://example.com/500")!),
            .failure(.serverError(status: 500))
        )

        try await XCTAsyncAssertEqual(
            await request(session: urlSession, url: URL(string: "https://example.com/offline")!),
            .failure(.offline)
        )

        try await XCTAsyncAssertEqual(
            await request(session: urlSession, url: URL(string: "https://example.com/timeout")!),
            .failure(.timeout)
        )

        try await XCTAsyncAssertEqual(
            await request(session: urlSession, url: URL(string: "https://example.com/cancelled")!),
            .failure(.cancelled)
        )

        try await XCTAsyncAssertEqual(
            await request(session: urlSession, url: URL(string: "https://example.com/other")!),
            .failure(.unknownError)
        )
    }
}
