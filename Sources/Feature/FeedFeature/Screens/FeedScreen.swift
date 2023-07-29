import Components
import CoreData
import DatabaseClient
import DeepLink
import Dependencies
import Entity
import Extension
import IdentifiedCollections
import MessageClient
import RSSClient
import SoundFileState
import SwiftUI
import UserDefaultsClient

@MainActor
public struct FeedScreen: View {
    @FetchRequest<EpisodeRecord>(sortDescriptors: []) private var episodeRecords: FetchedResults<EpisodeRecord>
    @FetchRequest<ShowRecord>(sortDescriptors: []) private var showRecords: FetchedResults<ShowRecord>
    
    private var episodes: [Episode] {
        episodeRecords.compactMap { $0.toEntity() }.sorted(by: { $0.publishedAt > $1.publishedAt })
    }
    
    @Environment(\.openURL) private var openURL
    @Environment(\.managedObjectContext) private var context
    
    @Dependency(\.messageClient) private var messageClient
    @Dependency(\.rssClient) private var rssClient
    @Dependency(\.userDefaultsClient) private var userDefaultsClient
    
    public init() {}
    
    public var body: some View {
        Group {
            if episodes.isEmpty {
                ContentUnavailableView(
                    label: {
                        Label(
                            title: { Text("No episodes in feed", bundle: .module) },
                            icon: { Image(systemName: "list.dash") }
                        )
                    },
                    actions: {
                        Button(action: { openURL(DeepLink.showSearch) }) {
                            Text("Follow your favorite shows!", bundle: .module)
                        }
                    }
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(episodes) { episode in
                            EpisodeRowView(
                                episode: episode,
                                showsPlayButton: true,
                                showsImage: true
                            )
                            
                            EpisodeDivider()
                        }
                    }
                    .padding(.horizontal)
                }
                .refreshable {
                    await refreshFeed()
                }
            }
        }
        .navigationTitle(Text("Feed", bundle: .module))
        .task {
            if let feedRefreshedAt = userDefaultsClient.getFeedRefreshedAt(),
               Date.now.timeIntervalSince(feedRefreshedAt) <= 600 {
                return
            }
            await refreshFeed()
        }
    }
}

private extension FeedScreen {
    func refreshFeed() async {
        await withTaskGroup(of: Void.self) { [rssClient] group in
            for showRecord in showRecords {
                group.addTask { @MainActor in
                    guard let feedURL = showRecord.feedURL else { return }
                    switch await rssClient.fetch(feedURL) {
                    case .success(let show):
                        let existingEpisodeIDs = Set((showRecord.episodes?.allObjects as? [EpisodeRecord])?.compactMap { $0.id } ?? [])
                        for episode in show.episodes where !existingEpisodeIDs.contains(episode.id) {
                            let episodeRecord = EpisodeRecord(context: context, episode: episode)
                            showRecord.addToEpisodes(episodeRecord)
                        }
                        context.saveWithErrorHandling { _ in }
                    case .failure:
                        // do not show error when update of one of shows failed
                        break
                    }
                }
            }
        }
        
        userDefaultsClient.setFeedRefreshedAt(.now)
    }
}
