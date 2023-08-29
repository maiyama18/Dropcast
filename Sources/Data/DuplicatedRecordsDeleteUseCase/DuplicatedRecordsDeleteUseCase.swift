@preconcurrency import CoreData
import Database
import Dependencies
import Foundation

public struct DuplicatedRecordsDeleteUseCase: Sendable {
    public var delete: @MainActor @Sendable () throws -> Void
}

extension DuplicatedRecordsDeleteUseCase {
    static func live(context: NSManagedObjectContext) -> DuplicatedRecordsDeleteUseCase {
        DuplicatedRecordsDeleteUseCase(
            delete: { @MainActor in
                struct EpisodeID {
                    let showFeedURL: URL
                    let id: String
                }
                
                let allShows = try context.fetch(ShowRecord.fetchRequest())
                let allShowFeedURLs = Set(allShows.map(\.feedURL_))
                for showFeedURL in allShowFeedURLs {
                    let shows = allShows.filter { $0.feedURL_ == showFeedURL }
                    if shows.count <= 1 { continue }
                    
                    // 残したいレコードが先頭に来るようにソートする。
                    // follow されていて、かつ episodes の数が多いものを優先して残す
                    let sortedShows = shows.sorted { s1, s2 in
                        // true -> s1 が先に来る
                        // false -> s2 が先に来る
                        if s1.followed && !s2.followed { return true }
                        if s2.followed && !s1.followed { return false }
                        return s1.episodes.count > s2.episodes.count
                    }
                    
                    for show in sortedShows.dropFirst() {
                        context.delete(show)
                    }
                }
                
                do {
                    try context.save()
                } catch {
                    context.rollback()
                }
                
                let allEpisodes = try context.fetch(EpisodeRecord.fetchRequest())
                let allEpisodeIDs: [EpisodeID] = allEpisodes.compactMap { episode -> EpisodeID? in
                    guard let feedURL = episode.show?.feedURL_ else { return nil }
                    return EpisodeID(showFeedURL: feedURL, id: episode.id)
                }
                for episodeID in allEpisodeIDs {
                    let episodes = allEpisodes.filter { $0.show?.feedURL_ == episodeID.showFeedURL && $0.id == episodeID.id }
                    if episodes.count <= 1 { continue }
                    
                    let sortedEpisodes = episodes.sorted { $0.publishedAt > $1.publishedAt }
                    
                    for episode in sortedEpisodes.dropFirst() {
                        context.delete(episode)
                    }
                }
                
                do {
                    try context.save()
                } catch {
                    context.rollback()
                }
            }
        )
    }
}

extension DuplicatedRecordsDeleteUseCase: DependencyKey {
    public static var liveValue: DuplicatedRecordsDeleteUseCase = .live(context: PersistentProvider.cloud.viewContext)
    public static var testValue: DuplicatedRecordsDeleteUseCase = DuplicatedRecordsDeleteUseCase(delete: unimplemented())
}

extension DependencyValues {
    public var duplicatedRecordsDeleteUseCase: DuplicatedRecordsDeleteUseCase {
        get { self[DuplicatedRecordsDeleteUseCase.self] }
        set { self[DuplicatedRecordsDeleteUseCase.self] = newValue }
    }
}
