import Database
import Dependencies
import Foundation
import RSSClient

public struct ShowCreateUseCase: Sendable {
    public var create: @MainActor @Sendable (_ feedURL: URL) async throws -> Void
}

extension ShowCreateUseCase {
    static var live: ShowCreateUseCase {
        @Dependency(\.rssClient) var rssClient
        
        return ShowCreateUseCase(
            create: { feedURL in
                let rssShow = try await rssClient.fetch(feedURL).get()
                try ShowRecord.deleteAll(with: feedURL)
                
                let show = ShowRecord(
                    title: rssShow.title,
                    description: rssShow.description,
                    author: rssShow.author,
                    feedURL: rssShow.feedURL,
                    imageURL: rssShow.imageURL,
                    linkURL: rssShow.imageURL
                )
                for episode in rssShow.episodes {
                    show.addToEpisodes_(
                        EpisodeRecord(
                            id: episode.id,
                            title: episode.title,
                            subtitle: episode.subtitle,
                            description: episode.description,
                            duration: episode.duration,
                            soundURL: episode.soundURL,
                            publishedAt: episode.publishedAt
                        )
                    )
                }
                
                try show.save()
            }
        )
    }
}

extension ShowCreateUseCase: DependencyKey {
    public static var liveValue: ShowCreateUseCase = .live
    public static var testValue: ShowCreateUseCase = ShowCreateUseCase(create: unimplemented())
}

extension DependencyValues {
    public var showCreateUseCase: ShowCreateUseCase {
        get { self[ShowCreateUseCase.self] }
        set { self[ShowCreateUseCase.self] = newValue }
    }
}
