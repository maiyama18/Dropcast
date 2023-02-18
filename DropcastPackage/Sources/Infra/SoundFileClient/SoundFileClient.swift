@preconcurrency import Combine
import Dependencies
import Entity
import Error
import Foundation
import Logger

public protocol SoundFileClient: Sendable {
    var downloadStatesPublisher: AnyPublisher<[String: EpisodeDownloadState], Never> { get }
    var downloadErrorPublisher: AnyPublisher<SoundFileClientError, Never> { get }
    
    func download(_ episode: Episode) async throws
    func cancelDownload(_ episode: Episode) async throws
}

actor SoundFileClientLive: SoundFileClient {
    struct TaskIdentifier: Codable, Hashable {
        var feedURLBase64: String
        var idBase64: String
        var soundFileName: String
        
        init?(episode: Episode) {
            guard let feedURLBase64 = episode.showFeedURL.absoluteString.base64Encoded(),
                  let idBase64 = episode.id.base64Encoded() else { return nil }
                  
            self.feedURLBase64 = feedURLBase64
            self.idBase64 = idBase64
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
    
    final class Delegate: NSObject, URLSessionDownloadDelegate, Sendable {
        private let onDownloadFinished: @Sendable (_ identifier: TaskIdentifier, _ data: Data) async throws -> Void
        private let onProgressUpdated: @Sendable (_ identifier: TaskIdentifier, _ progress: Double) async -> Void
        private let onErrorOccurred: @Sendable (_ identifier: TaskIdentifier?, _ error: Error) async -> Void
        
        private let decoder = JSONDecoder()
        
        init(
            onDownloadFinished: @escaping @Sendable (SoundFileClientLive.TaskIdentifier, Data) async throws -> Void,
            onProgressUpdated: @escaping @Sendable (SoundFileClientLive.TaskIdentifier, Double) async -> Void,
            onErrorOccurred: @escaping @Sendable (_ identifier: TaskIdentifier?, _ error: Error) async -> Void
        ) {
            self.onDownloadFinished = onDownloadFinished
            self.onProgressUpdated = onProgressUpdated
            self.onErrorOccurred = onErrorOccurred
        }
        
        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            if let error {
                Task { await handleDelegateError(session: session, error: error) }
            }
        }
        
        func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
            if let error {
                Task { await handleDelegateError(session: session, error: error) }
            }
        }
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            guard let identifierString = session.configuration.identifier,
                  let identifier = TaskIdentifier(string: identifierString),
                  let data = try? Data(contentsOf: location) else {
                Task {
                    await onErrorOccurred(nil, SoundFileClientError.unexpectedError)
                }
                return
            }
            
            Task {
                do {
                    try await onDownloadFinished(identifier, data)
                } catch {
                    await onErrorOccurred(identifier, error)
                }
            }
        }
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
            guard let identifierString = session.configuration.identifier,
                  let identifier = TaskIdentifier(string: identifierString) else {
                return
            }
            let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            Task {
                await onProgressUpdated(identifier, progress)
            }
        }
        
        private func handleDelegateError(session: URLSession, error: Error?) async {
            var identifier: TaskIdentifier?
            if let identifierString = session.configuration.identifier {
               identifier = TaskIdentifier(string: identifierString)
            }
            
            await onErrorOccurred(identifier, SoundFileClientError.downloadError)
        }
    }
    
    static let shared: SoundFileClientLive = .init()
    
    @Dependency(\.logger[.soundFile]) var logger
    
    private let documentDirectoryURL: URL
    private let sessionProvider: @Sendable (_ configuration: URLSessionConfiguration, _ delegate: URLSessionDownloadDelegate) -> URLSession
    
    nonisolated public var downloadStatesPublisher: AnyPublisher<[String: EpisodeDownloadState], Never> {
        downloadStatesSubject.eraseToAnyPublisher()
    }
    private let downloadStatesSubject: CurrentValueSubject<[String: EpisodeDownloadState], Never> = .init([:])
    
    nonisolated public var downloadErrorPublisher: AnyPublisher<SoundFileClientError, Never> {
        downloadErrorSubject.eraseToAnyPublisher()
    }
    private let downloadErrorSubject: PassthroughSubject<SoundFileClientError, Never> = .init()
    
    private lazy var delegate = Delegate(
        onDownloadFinished: { [weak self] identifier, data in
            guard let self else { return }
            
            @Dependency(\.logger[.soundFile]) var logger
            
            let directoryURL = self.documentDirectoryURL
                .appendingPathComponent("SoundFiles")
                .appendingPathComponent(identifier.feedURLBase64)
                .appendingPathComponent(identifier.idBase64)
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            } catch {
                guard (error as? CocoaError)?.code == CocoaError.fileWriteFileExists else {
                    logger.error("failed to make directory: \(error, privacy: .public)")
                    throw SoundFileClientError.downloadError
                }
            }
            
            let fileURL = directoryURL.appendingPathComponent(identifier.soundFileName)
            do {
                try data.write(to: fileURL)
                logger.notice("download file saved \(identifier.idBase64, privacy: .public): \(fileURL)")
                await self.updateDownloadState(identifier: identifier, downloadState: .downloaded)
            } catch {
                logger.error("failed to save downloaded file \(identifier.idBase64, privacy: .public): \(error, privacy: .public)")
                throw SoundFileClientError.downloadError
            }
        },
        onProgressUpdated: { [weak self] identifier, progress in
            guard let self else { return }
            await self.updateDownloadState(identifier: identifier, downloadState: .downloading(progress: progress))
        },
        onErrorOccurred: { [weak self] identifier, error in
            guard let self else { return }
            
            @Dependency(\.logger[.soundFile]) var logger
            
            self.downloadErrorSubject.send(.downloadError)
            
            logger.error("failed to download file \(identifier?.idBase64 ?? "", privacy: .public): \(error, privacy: .public)")
            
            guard let identifier else { return }
            await self.updateDownloadState(identifier: identifier, downloadState: .notDownloaded)
        }
    )
    
    private var tasks: [TaskIdentifier: URLSessionDownloadTask] = [:]
    
    init(
        documentDirectoryURL: URL = .documentsDirectory,
        sessionProvider: @escaping @Sendable (
            _ configuration: URLSessionConfiguration,
            _ delegate: URLSessionDownloadDelegate
        ) -> URLSession = {
            URLSession(configuration: $0, delegate: $1, delegateQueue: nil)
        }
    ) {
        self.documentDirectoryURL = documentDirectoryURL
        self.sessionProvider = sessionProvider
        
        Task { await initializeDownloadStates() }
    }
    
    func download(_ episode: Episode) async throws {
        guard let identifier = TaskIdentifier(episode: episode),
              let identifierString = identifier.string() else {
            logger.notice("failed to make identifierString")
            throw SoundFileClientError.unexpectedError
        }
        
        logger.notice("downloading episode: \(identifier.idBase64) \(episode.showTitle) \(episode.title)")
        
        self.updateDownloadState(identifier: identifier, downloadState: .pushedToDownloadQueue)

        let configuration = URLSessionConfiguration.background(withIdentifier: identifierString)
        let session = sessionProvider(configuration, delegate)
        let task = session.downloadTask(with: episode.soundURL)
        tasks[identifier] = task
        task.resume()
    }
    
    func cancelDownload(_ episode: Episode) async throws {
        guard let identifier = TaskIdentifier(episode: episode) else {
            throw SoundFileClientError.unexpectedError
        }
        
        logger.notice("download cancelled: \(identifier.idBase64) \(episode.showTitle) \(episode.title)")
        
        updateDownloadState(identifier: identifier, downloadState: .notDownloaded)
        tasks[identifier]?.cancel()
    }
    
    private func initializeDownloadStates() {
        guard let enumerator = FileManager.default.enumerator(
            at: self.documentDirectoryURL.appendingPathComponent("SoundFiles"),
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            return
        }
        
        // ref: https://stackoverflow.com/questions/57640119/listing-all-files-in-a-folder-recursively-with-swift
        var downloadStates: [String: EpisodeDownloadState] = [:]
        for case let fileURL as URL in enumerator {
            guard (try? fileURL.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true else { continue }
            
            let idIndex = fileURL.pathComponents.count - 2
            guard idIndex >= 0,
                  let id = String(base64Encoded: fileURL.pathComponents[idIndex]) else { continue }
            
            downloadStates[id] = .downloaded
        }
        
        downloadStatesSubject.send(downloadStates)
    }
    
    private func updateDownloadState(identifier: TaskIdentifier, downloadState: EpisodeDownloadState) {
        guard let id = String(base64Encoded: identifier.idBase64) else { return }
        
        var downloadStates = downloadStatesSubject.value
        downloadStates[id] = downloadState
        downloadStatesSubject.send(downloadStates)
    }
}

public enum SoundFileClientKey: DependencyKey {
    public static let liveValue: SoundFileClient = SoundFileClientLive.shared
    public static let testValue: SoundFileClient = SoundFileClientMock()
}

extension DependencyValues {
    public var soundFileClient: any SoundFileClient {
        get { self[SoundFileClientKey.self] }
        set { self[SoundFileClientKey.self] = newValue }
    }
}

public actor SoundFileClientMock: SoundFileClient {
    @Dependency(\.continuousClock) var clock
    
    private var tasks: [String: Task<Void, Error>] = [:]
    
    nonisolated public var downloadStatesPublisher: AnyPublisher<[String: EpisodeDownloadState], Never> {
        downloadStatesSubject.eraseToAnyPublisher()
    }
    private let downloadStatesSubject: CurrentValueSubject<[String: EpisodeDownloadState], Never> = .init([:])
    
    nonisolated public var downloadErrorPublisher: AnyPublisher<SoundFileClientError, Never> {
        downloadErrorSubject.eraseToAnyPublisher()
    }
    private let downloadErrorSubject: PassthroughSubject<SoundFileClientError, Never> = .init()
    
    public var error: SoundFileClientError?
    
    public init() {}
    
    public func setError(error: SoundFileClientError?) {
        self.error = error
    }
    
    public func download(_ episode: Episode) async throws {
        let task = Task {
            updateDownloadState(id: episode.id, downloadState: .pushedToDownloadQueue)
            
            try await clock.sleep(for: .seconds(1))
            
            updateDownloadState(id: episode.id, downloadState: .downloading(progress: 0))
            
            try await clock.sleep(for: .seconds(5))
            
            if let error {
                downloadErrorSubject.send(error)
                self.error = nil
                updateDownloadState(id: episode.id, downloadState: .notDownloaded)
                return
            }
            
            updateDownloadState(id: episode.id, downloadState: .downloading(progress: 0.5))
            
            try await clock.sleep(for: .seconds(5))
            
            updateDownloadState(id: episode.id, downloadState: .downloaded)
        }
        tasks[episode.id] = task
        try await task.value
    }
    
    public func cancelDownload(_ episode: Episode) async throws {
        tasks[episode.id]?.cancel()
        updateDownloadState(id: episode.id, downloadState: .notDownloaded)
    }
    
    private func updateDownloadState(id: Episode.ID, downloadState: EpisodeDownloadState) {
        var downloadStates = downloadStatesSubject.value
        downloadStates[id] = downloadState
        downloadStatesSubject.send(downloadStates)
    }
}
