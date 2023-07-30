import Combine
import Dependencies
import Entity
import Error
import Foundation
import Logger
import Observation

/// 音声ファイルの状態を管理するシングルトンのオブジェクト。
/// 音声ファイルは <DocumentDirectory>/SoundFiles/<FeedURL の Base64>/<EpisodeID の Base64>/<音声ファイル名> という階層で保存されている。
/// この階層で保存するため、ダウンロードの進捗時や完了時に Delegate で受け取る Identifier に FeedURL の Base64 / EpisodeID の Base64 / 音声ファイル名 が埋め込まれている TaskIdentifier を利用している。
@Observable
public final class SoundFileState: NSObject {
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
        
        func episodeID() -> Episode.ID? {
            String(base64Encoded: idBase64)
        }
    }
    
    struct UnexpectedError: Error {}
    
    public static let shared: SoundFileState = .init()
    
    public var downloadStates: [Episode.ID: EpisodeDownloadState] = [:]
    public let downloadErrorPublisher: PassthroughSubject<Void, Never> = .init()
    
    public var soundFilesRootDirectoryURL: URL { URL.documentsDirectory.appendingPathComponent("SoundFiles") }
    private var tasks: [TaskIdentifier: URLSessionDownloadTask] = [:]
    
    @ObservationIgnored @Dependency(\.logger[.soundFile]) var logger
    
    override private init() {
        super.init()
        self.initializeDownloadStates()
    }

    public func startDownload(episode: Episode) throws {
        guard let identifier = TaskIdentifier(episode: episode),
              let identifierString = identifier.string() else {
            logger.notice("failed to make identifierString")
            throw UnexpectedError()
        }

        logger.notice("downloading episode: \(identifier.idBase64) \(episode.showTitle) \(episode.title)")

        downloadStates[episode.id] = .pushedToDownloadQueue

        let configuration = URLSessionConfiguration.background(withIdentifier: identifierString)
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: episode.soundURL)
        tasks[identifier] = task
        task.resume()
    }
    
    public func cancelDownload(episode: Episode) {
        downloadStates[episode.id] = .notDownloaded
        
        guard let identifier = TaskIdentifier(episode: episode) else {
            return
        }
        
        logger.notice("canceling download episode: \(identifier.idBase64) \(episode.showTitle) \(episode.title)")
        
        tasks[identifier]?.cancel()
        tasks.removeValue(forKey: identifier)
    }
    
    private func initializeDownloadStates() {
        if !FileManager.default.fileExists(atPath: soundFilesRootDirectoryURL.path()) {
            try? FileManager.default.createDirectory(at: soundFilesRootDirectoryURL, withIntermediateDirectories: true)
        }

        guard let enumerator = FileManager.default.enumerator(
            at: self.soundFilesRootDirectoryURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            return
        }

        // ref: https://stackoverflow.com/questions/57640119/listing-all-files-in-a-folder-recursively-with-swift
        for case let fileURL as URL in enumerator {
            guard (try? fileURL.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true else { continue }

            let episodeIDIndex = fileURL.pathComponents.count - 2
            guard episodeIDIndex >= 0,
                  let episodeID = String(base64Encoded: fileURL.pathComponents[episodeIDIndex]) else { continue }

            downloadStates[episodeID] = .downloaded(url: fileURL)
        }
    }
}

extension SoundFileState: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error {
            handleDelegateError(session: session, error: error)
        }
    }

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let error {
            handleDelegateError(session: session, error: error)
        }
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let identifierString = session.configuration.identifier,
              let identifier = TaskIdentifier(string: identifierString),
              let episodeID = identifier.episodeID(),
              let data = try? Data(contentsOf: location) else {
            handleDelegateError(session: session, error: UnexpectedError())
            return
        }
        
        let directoryURL = self.soundFilesRootDirectoryURL
            .appendingPathComponent(identifier.feedURLBase64)
            .appendingPathComponent(identifier.idBase64)
        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        } catch {
            guard (error as? CocoaError)?.code == CocoaError.fileWriteFileExists else {
                logger.fault("failed to make directory: \(error, privacy: .public)")
                handleDelegateError(session: session, error: UnexpectedError())
                return
            }
        }
        
        let fileURL = directoryURL.appendingPathComponent(identifier.soundFileName)
        do {
            try data.write(to: fileURL)
            logger.notice("download file saved \(identifier.idBase64, privacy: .public): \(fileURL)")
            downloadStates[episodeID] = .downloaded(url: fileURL)
        } catch {
            logger.fault("failed to save downloaded file \(identifier.idBase64, privacy: .public): \(error, privacy: .public)")
            handleDelegateError(session: session, error: UnexpectedError())
        }
    }

    public func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard let identifierString = session.configuration.identifier,
              let identifier = TaskIdentifier(string: identifierString),
              let episodeID = identifier.episodeID() else {
            return
        }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        downloadStates[episodeID] = .downloading(progress: progress)
    }

    private func handleDelegateError(session: URLSession, error: Error) {
        downloadErrorPublisher.send(())
        
        guard let identifierString = session.configuration.identifier,
              let episodeID = TaskIdentifier(string: identifierString)?.episodeID() else {
            logger.fault("failed to download file and identifier cannot be retrieved: \(error, privacy: .public)")
            return
        }

        downloadStates[episodeID] = .notDownloaded
        logger.fault("failed to download file \(episodeID, privacy: .public): \(error, privacy: .public)")
    }
}
