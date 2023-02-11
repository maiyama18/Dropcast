import Dependencies
import Entity
@preconcurrency import Foundation

public protocol SoundFileClient: Sendable {
    func download(_ episode: Episode) async throws
}

actor SoundFileClientLive: SoundFileClient {
    final class Delegate: NSObject, URLSessionDownloadDelegate {
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            print("[Download] finished", location)
        }
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
            let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            print("[Download] progress", progress)
        }
    }
    
    static let shared: SoundFileClientLive = .init(urlSession: .shared)
    
    private let urlSession: URLSession
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    
    func download(_ episode: Episode) async throws {
        let delegate = Delegate()
        let (_, response) = try await urlSession.download(from: episode.soundURL, delegate: delegate)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        print("[Download] download finished", status)
    }
}

public enum SoundFileClientKey: DependencyKey {
    public static let liveValue: SoundFileClient = SoundFileClientLive.shared
}

extension DependencyValues {
    public var soundFileClient: SoundFileClient {
        get { self[SoundFileClientKey.self] }
        set { self[SoundFileClientKey.self] = newValue }
    }
}
