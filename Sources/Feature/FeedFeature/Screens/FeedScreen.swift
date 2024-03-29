import Algorithms
import Components
import CoreData
import Database
import DeepLink
import Dependencies
import Entity
import EpisodeDetailFeature
import Extension
import IdentifiedCollections
import MessageClient
import NavigationState
import RSSClient
import ShowDetailFeature
import ShowEpisodesUpdateUseCase
import SoundFileState
import SwiftUI
import UserDefaultsClient

@MainActor
public struct FeedScreen: View {
    @FetchRequest<EpisodeRecord>(fetchRequest: EpisodeRecord.followed()) private var episodes: FetchedResults<EpisodeRecord>
    @FetchRequest<ShowRecord>(fetchRequest: ShowRecord.followed()) private var shows: FetchedResults<ShowRecord>
    
    @Environment(NavigationState.self) private var navigationState
    @Environment(\.openURL) private var openURL
    @Environment(\.managedObjectContext) private var context
    @Environment(\.playerBannerHeight) private var playerBannerHeight
    
    @Dependency(\.messageClient) private var messageClient
    @Dependency(\.rssClient) private var rssClient
    @Dependency(\.userDefaultsClient) private var userDefaultsClient
    
    @Dependency(\.showEpisodesUpdateUseCase) private var showEpisodesUpdateUseCase
    
    public init() {}
    
    public var body: some View {
        NavigationStack(path: .init(get: { navigationState.feedPath }, set: { navigationState.feedPath = $0 })) {
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
                            ForEach(episodes.uniqued(on: { $0.id }), id: \.objectID) { episode in
                                NavigationLink(
                                    value: PodcastRoute.episodeDetail(episode: episode)
                                ) {
                                    EpisodeRowView(
                                        episode: episode,
                                        showsImage: true
                                    )
                                }
                                
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
            .navigationDestination(for: PodcastRoute.self) { route in
                switch route {
                case .episodeDetail(let episode):
                    EpisodeDetailScreen(episode: episode)
                case .showDetail(let args):
                    ShowDetailScreen(args: args)
                }
            }
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
        await withTaskGroup(of: Void.self) { [showEpisodesUpdateUseCase] group in
            for show in shows {
                group.addTask { @MainActor in
                    do {
                        try await showEpisodesUpdateUseCase.update(show)
                    } catch {
                        // do nothing
                    }
                }
            }
        }
        
        userDefaultsClient.setFeedRefreshedAt(.now)
    }
}
