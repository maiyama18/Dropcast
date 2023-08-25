import Database
import Dependencies
import RSSClient

public struct ShowEpisodesUpdateUseCase: Sendable {
    public var update: @MainActor @Sendable (_ show: ShowRecord) async throws -> Void
}

extension ShowEpisodesUpdateUseCase {
    static var live: ShowEpisodesUpdateUseCase {
        @Dependency(\.rssClient) var rssClient
        
        return ShowEpisodesUpdateUseCase(
            update: { show in
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
                try show.save()
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
