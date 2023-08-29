import Database
import Dependencies
import Foundation
import RSSClient

public struct ShowEpisodesUpdateUseCase: Sendable {
    public var update: @MainActor @Sendable (_ show: ShowRecord) async throws -> Void
}

extension ShowEpisodesUpdateUseCase {
    static var live: ShowEpisodesUpdateUseCase {
        @Dependency(\.rssClient) var rssClient
        
        return ShowEpisodesUpdateUseCase(
            update: { show in
                guard let context = show.managedObjectContext else {
                    throw NSError(domain: "no context", code: 0)
                }
                
                let rssShow = try await rssClient.fetch(show.feedURL).get()
                let existingEpisodeIDs = Set(show.episodes.map(\.id))
                for rssEpisode in rssShow.episodes where !existingEpisodeIDs.contains(rssEpisode.id) {
                    show.addToEpisodes_(
                        EpisodeRecord(
                            id: rssEpisode.id,
                            title: rssEpisode.title,
                            subtitle: rssEpisode.subtitle,
                            description: rssEpisode.description,
                            duration: rssEpisode.duration,
                            soundURL: rssEpisode.soundURL,
                            publishedAt: rssEpisode.publishedAt
                        )
                    )
                }
                do {
                    try context.save()
                } catch {
                    context.rollback()
                    throw error
                }
            }
        )
    }
}

extension ShowEpisodesUpdateUseCase: DependencyKey {
    public static var liveValue: ShowEpisodesUpdateUseCase = .live
    public static var testValue: ShowEpisodesUpdateUseCase = ShowEpisodesUpdateUseCase(update: unimplemented())
}

extension DependencyValues {
    public var showEpisodesUpdateUseCase: ShowEpisodesUpdateUseCase {
        get { self[ShowEpisodesUpdateUseCase.self] }
        set { self[ShowEpisodesUpdateUseCase.self] = newValue }
    }
}
