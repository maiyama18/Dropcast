import Components
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
    @State private var episodes: IdentifiedArrayOf<Episode>? = nil
    
    @Dependency(\.openURL) private var openURL
    
    @Dependency(\.databaseClient) private var databaseClient
    @Dependency(\.messageClient) private var messageClient
    @Dependency(\.rssClient) private var rssClient
    @Dependency(\.userDefaultsClient) private var userDefaultsClient

    public init() {}

    public var body: some View {
        Group {
            if let episodes {
                if episodes.isEmpty {
                    ContentUnavailableView(
                        label: {
                            Label(
                                title: { Text("No episodes in feed", bundle: .module) },
                                icon: { Image(systemName: "list.dash") }
                            )
                        },
                        actions: {
                            Button(action: { Task { await openURL(DeepLink.showSearch) } }) {
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
            } else {
                ProgressView()
                    .scaleEffect(2)
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
        .task {
            for await episodes in databaseClient.followedEpisodesStream() {
                self.episodes = episodes
            }
        }
    }
}

private extension FeedScreen {
    func refreshFeed() async {
        let shows: [Show]
        switch databaseClient.fetchFollowedShows() {
        case .success(let followedShows):
            shows = followedShows.elements
        case .failure:
            messageClient.presentError(String(localized: "Failed to communicate with database", bundle: .module))
            return
        }

        await withTaskGroup(of: Void.self) { [rssClient, databaseClient] group in
            for show in shows {
                group.addTask {
                    switch await rssClient.fetch(show.feedURL) {
                    case .success(let show):
                        _ = databaseClient.addNewEpisodes(show)
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
