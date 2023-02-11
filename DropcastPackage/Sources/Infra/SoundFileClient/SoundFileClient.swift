import Dependencies
import Entity
import Error
@preconcurrency import Foundation

public protocol SoundFileClient: Sendable {
    func download(_ episode: Episode) async throws
}

actor SoundFileClientLive: SoundFileClient {
    struct TaskIdentifier: Codable, Hashable {
        var feedURLBase64: String
        var guidBase64: String
        var soundFileName: String
        
        init?(episode: Episode) {
            guard let feedURLBase64 = episode.showFeedURL.absoluteString.data(using: .utf8)?.base64EncodedString(),
                  let guidBase64 = episode.guid.data(using: .utf8)?.base64EncodedString() else { return nil }
                  
            self.feedURLBase64 = feedURLBase64
            self.guidBase64 = guidBase64
            self.soundFileName = episode.soundURL.lastPathComponent
        }
        
        init?(string: String) {
            guard let data = string.data(using: .utf8) else { return nil }
            guard let result = try? JSONDecoder().decode(TaskIdentifier.self, from: data) else { return nil }
            self = result
        }
        
        func string() -> String? {
            guard let data = try? JSONEncoder().encode(self) else { return nil }
            return String(data: data, encoding: .utf8)
        }
    }
    
    final class Delegate: NSObject, URLSessionDownloadDelegate {
        private let onDownloadFinished: (_ identifier: TaskIdentifier, _ temporaryFileURL: URL) throws -> Void
        private let onProgressUpdated: (_ identifier: TaskIdentifier, _ progress: Double) -> Void
        private let onErrorOccurred: (Error) -> Void
        
        private let decoder = JSONDecoder()
        
        init(
            onDownloadFinished: @escaping (SoundFileClientLive.TaskIdentifier, URL) throws -> Void,
            onProgressUpdated: @escaping (SoundFileClientLive.TaskIdentifier, Double) -> Void,
            onErrorOccurred: @escaping (Error) -> Void
        ) {
            self.onDownloadFinished = onDownloadFinished
            self.onProgressUpdated = onProgressUpdated
            self.onErrorOccurred = onErrorOccurred
        }
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            guard let identifierString = session.configuration.identifier,
                  let identifier = TaskIdentifier(string: identifierString) else {
                onErrorOccurred(SoundFileClientError.unexpectedError)
                return
            }
            do {
                try onDownloadFinished(identifier, location)
            } catch {
                onErrorOccurred(error)
            }
        }
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
            guard let identifierString = session.configuration.identifier,
                  let identifier = TaskIdentifier(string: identifierString) else {
                return
            }
            let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            onProgressUpdated(identifier, progress)
        }
    }
    
    static let shared: SoundFileClientLive = .init()
    
    private lazy var delegate = Delegate(
        onDownloadFinished: { identifier, temporaryFileURL in
            let directoryURL = URL.documentsDirectory
                .appendingPathComponent(identifier.feedURLBase64)
                .appendingPathComponent(identifier.guidBase64)
            print("[D] directoryURL", directoryURL)
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            } catch {
                guard (error as? CocoaError)?.code == CocoaError.fileWriteFileExists else {
                    throw SoundFileClientError.downloadError
                }
            }
            
            let fileURL = directoryURL.appendingPathComponent(identifier.soundFileName)
            do {
                try FileManager.default.moveItem(at: temporaryFileURL, to: fileURL)
                print("[D] complete", fileURL)
            } catch {
                throw SoundFileClientError.downloadError
            }
        },
        onProgressUpdated: { identifier, progress in
            print("[D]", identifier, progress)
        },
        onErrorOccurred: { error in
            print("[D]", error)
        }
    )
    
    private var tasks: [TaskIdentifier: URLSessionDownloadTask] = [:]
    
    func download(_ episode: Episode) async throws {
        guard let identifier = TaskIdentifier(episode: episode),
              let identifierString = identifier.string() else {
            throw SoundFileClientError.unexpectedError
        }
        
        let configuration = URLSessionConfiguration.background(withIdentifier: identifierString)
        let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        let task = session.downloadTask(with: episode.soundURL)
        tasks[identifier] = task
        task.resume()
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
