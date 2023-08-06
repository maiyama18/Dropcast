import Components
import CoreData
import Database
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
    // TODO: ソート && 重複をなくす && valid な record にフィルタする
    @FetchRequest<EpisodeRecord>(sortDescriptors: []) private var episodes: FetchedResults<EpisodeRecord>
    @FetchRequest<ShowRecord>(sortDescriptors: []) private var shows: FetchedResults<ShowRecord>
    
    @Environment(\.openURL) private var openURL
    @Environment(\.managedObjectContext) private var context
    
    @Dependency(\.messageClient) private var messageClient
    @Dependency(\.rssClient) private var rssClient
    @Dependency(\.userDefaultsClient) private var userDefaultsClient
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
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
            for show in shows {
                group.addTask { @MainActor in
                    switch await rssClient.fetch(show.feedURL) {
                    case .success(let show):
                        let existingEpisodeIDs = Set(show.episodes.map { $0.id } ?? [])
                        for episode in show.episodes where !existingEpisodeIDs.contains(episode.id) {
                            show.addToEpisodes_(episode)
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
