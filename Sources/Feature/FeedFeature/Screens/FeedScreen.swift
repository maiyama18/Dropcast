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
    @FetchRequest<EpisodeRecord>(fetchRequest: EpisodeRecord.followed()) private var episodes: FetchedResults<EpisodeRecord>
    @FetchRequest<ShowRecord>(fetchRequest: ShowRecord.followed()) private var shows: FetchedResults<ShowRecord>
 
    @Environment(\.openURL) private var openURL
    @Environment(\.managedObjectContext) private var context
    @Environment(\.playerBannerHeight) private var playerBannerHeight
    
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
                            ForEach(episodes, id: \.objectID) { episode in
                                EpisodeRowView(
                                    episode: episode,
                                    showsPlayButton: true,
                                    showsImage: true
                                )
                                
                                EpisodeDivider()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, playerBannerHeight)
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
                    do {
                        let rssShow = try await rssClient.fetch(show.feedURL).get()
                        let existingEpisodeIDs = Set(show.episodes.map(\.id))
                        for rssEpisode in rssShow.episodes where !existingEpisodeIDs.contains(rssEpisode.id) {
                            show.addToEpisodes_(rssEpisode.toModel(context: context))
                        }
                        try show.save()
                    } catch {
                        // do nothing
                    }
                }
            }
        }
        
        userDefaultsClient.setFeedRefreshedAt(.now)
    }
}
