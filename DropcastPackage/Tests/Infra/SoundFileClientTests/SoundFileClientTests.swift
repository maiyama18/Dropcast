import Clocks
import CustomDump
import Entity
import TestHelper
import XCTest

@testable import SoundFileClient

final class URLSessionDownloadTaskMock: URLSessionDownloadTask {
    private let operation: () async throws -> Void
    
    init(operation: @escaping () async throws -> Void) {
        self.operation = operation
    }
    
    override func resume() {
        Task { try await operation() }
    }
}

final class URLSessionMock: URLSession {
    let downloadTask: URLSessionDownloadTask
    
    init(operation: @escaping () async throws -> Void) {
        self.downloadTask = URLSessionDownloadTaskMock(operation: operation)
    }
    
    override func downloadTask(with url: URL) -> URLSessionDownloadTask {
        return downloadTask
    }
}

final class SoundFileClientTests: XCTestCase {
    func test_download_success() async throws {
        let temporaryFileURL = URL.temporaryDirectory.appendingPathComponent("temporaryFile")
        try "HelloWorld".data(using: .utf8)!.write(to: temporaryFileURL)
        
        let clock = TestClock()
        let client = SoundFileClientLive(
            documentDirectoryURL: URL.temporaryDirectory,
            sessionProvider: { configuration, delegate in
                let dummySession = URLSession(configuration: configuration)
                let dummyTask = dummySession.downloadTask(with: URLRequest(url: URL(string: "https://example.com")!))
                
                return URLSessionMock {
                    try await clock.sleep(for: .seconds(1))
                    delegate.urlSession?(
                        dummySession,
                        downloadTask: dummyTask,
                        didWriteData: 5,
                        totalBytesWritten: 5,
                        totalBytesExpectedToWrite: 10
                    )
                    try await clock.sleep(for: .seconds(1))
                    delegate.urlSession(
                        dummySession,
                        downloadTask: dummyTask,
                        didFinishDownloadingTo: temporaryFileURL
                    )
                }
            }
        )
        
        try await client.download(.fixtureRebuild350)
        
        try XCTAssertReceive(
            from: client.downloadStatesPublisher,
            [Episode.fixtureRebuild350.guid: .pushedToDownloadQueue]
        )
        
        await clock.advance(by: .seconds(1))
        try XCTAssertReceive(
            from: client.downloadStatesPublisher,
            [Episode.fixtureRebuild350.guid: .downloading(progress: 0.5)]
        )
        
        await clock.advance(by: .seconds(1))
        try XCTAssertReceive(
            from: client.downloadStatesPublisher,
            [Episode.fixtureRebuild350.guid: .downloaded]
        )
        
        let destinationFileURL = URL.temporaryDirectory
            .appendingPathComponent("SoundFiles")
            .appendingPathComponent(Episode.fixtureRebuild350.showFeedURL.absoluteString.base64Encoded()!)
            .appendingPathComponent(Episode.fixtureRebuild350.guid.base64Encoded()!)
            .appendingPathComponent(Episode.fixtureRebuild350.soundURL.lastPathComponent)
        
        let data = try Data(contentsOf: destinationFileURL)
        
        XCTAssertNoDifference(String(data: data, encoding: .utf8), "HelloWorld")
    }
    
    func test_download_failure() async throws {
        let clock = TestClock()
        let client = SoundFileClientLive(
            documentDirectoryURL: URL.temporaryDirectory,
            sessionProvider: { configuration, delegate in
                let dummySession = URLSession(configuration: configuration)
                let dummyTask = dummySession.downloadTask(with: URLRequest(url: URL(string: "https://example.com")!))
                
                return URLSessionMock {
                    try await clock.sleep(for: .seconds(1))
                    delegate.urlSession?(
                        dummySession,
                        downloadTask: dummyTask,
                        didWriteData: 5,
                        totalBytesWritten: 5,
                        totalBytesExpectedToWrite: 10
                    )
                    try await clock.sleep(for: .seconds(1))
                    delegate.urlSession?(
                        dummySession,
                        task: dummyTask,
                        didCompleteWithError: NSError(domain: "download", code: 0)
                    )
                }
            }
        )
        
        try await client.download(.fixtureRebuild350)
        
        try XCTAssertReceive(
            from: client.downloadStatesPublisher,
            [Episode.fixtureRebuild350.guid: .pushedToDownloadQueue]
        )
        
        await clock.advance(by: .seconds(1))
        try XCTAssertReceive(
            from: client.downloadStatesPublisher,
            [Episode.fixtureRebuild350.guid: .downloading(progress: 0.5)]
        )
        
        await XCTAssertReceive(
            from: client.downloadErrorPublisher,
            .downloadError
        ) {
            await clock.advance(by: .seconds(1))
        }
        
        try XCTAssertReceive(
            from: client.downloadStatesPublisher,
            [Episode.fixtureRebuild350.guid: .notDownloaded]
        )
    }
}
