import AVFoundation
import Dependencies
import Foundation

public struct Chapter: Sendable, Equatable {
    public let title: String
    public let startsAt: TimeInterval
    public let endsAt: TimeInterval
    public let duration: TimeInterval
}

public struct PodcastChapterExtractUseCase: Sendable {
    public var extract: @Sendable (_ fileURL: URL) async throws -> [Chapter]
}

extension PodcastChapterExtractUseCase {
    static var live: PodcastChapterExtractUseCase {
        PodcastChapterExtractUseCase(
            extract: { fileURL in
                let asset = AVAsset(url: fileURL)
                
                let availableLocales = try await asset.load(.availableChapterLocales)
                guard let availableLocale = availableLocales.first else {
                    return []
                }
                
                let chapterMetadataList = try await asset.loadChapterMetadataGroups(withTitleLocale: availableLocale)
                
                var chapters: [Chapter] = []
                for metadata in chapterMetadataList {
                    guard let titleItem = metadata.items.first(where: { $0.commonKey == .commonKeyTitle }),
                          let title = try? await titleItem.load(.value) as? String else {
                        continue
                    }
                    chapters.append(
                        Chapter(
                            title: title,
                            startsAt: metadata.timeRange.start.seconds,
                            endsAt: metadata.timeRange.end.seconds,
                            duration: metadata.timeRange.duration.seconds
                        )
                    )
                }
                return chapters
            }
        )
    }
}

extension PodcastChapterExtractUseCase: DependencyKey {
    public static var liveValue: PodcastChapterExtractUseCase = .live
    public static var testValue: PodcastChapterExtractUseCase = PodcastChapterExtractUseCase(extract: unimplemented())
}

extension DependencyValues {
    public var podcastChapterExtractUseCase: PodcastChapterExtractUseCase {
        get { self[PodcastChapterExtractUseCase.self] }
        set { self[PodcastChapterExtractUseCase.self] = newValue }
    }
}
