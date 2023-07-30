import Foundation

public enum EpisodeDownloadState: Sendable, Equatable {
    case notDownloaded
    case pushedToDownloadQueue
    case downloading(progress: Double)
    case downloaded(url: URL)
}
