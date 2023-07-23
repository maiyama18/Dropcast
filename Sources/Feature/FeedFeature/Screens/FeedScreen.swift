import Components
import DatabaseClient
import DeepLink
import Dependencies
import Entity
import Extension
import IdentifiedCollections
import MessageClient
import RSSClient
import SoundFileClient
import SwiftUI
import UserDefaultsClient

@MainActor
public struct FeedScreen: View {
    @State private var episodes: IdentifiedArrayOf<Episode>? = nil
    @State private var downloadStates: [Episode.ID: EpisodeDownloadState] = [:]
    
    @Dependency(\.openURL) private var openURL
    
    @Dependency(\.databaseClient) private var databaseClient
    @Dependency(\.messageClient) private var messageClient
    @Dependency(\.rssClient) private var rssClient
    @Dependency(\.soundFileClient) private var soundFileClient
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
                                    downloadState: downloadState(id: episode.id),
                                    showsPlayButton: true,
                                    showsImage: true,
                                    onDownloadButtonTapped: {
                                        Task {
                                            switch downloadState(id: episode.id) {
                                            case .notDownloaded:
                                                try await soundFileClient.download(episode)
                                            case .pushedToDownloadQueue:
                                                break
                                            case .downloading:
                                                try await soundFileClient.cancelDownload(episode)
                                            case .downloaded:
                                                // TODO: play sound
                                                break
                                            }
                                        }
                                    }
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
        .task {
            for await downloadStates in soundFileClient.downloadStatesPublisher.eraseToStream() {
                self.downloadStates = downloadStates
            }
        }
        .task {
            for await downloadError in soundFileClient.downloadErrorPublisher.eraseToStream() {
                let message: String
                switch downloadError {
                case .unexpectedError:
                    message = String(localized: "Something went wrong", bundle: .module)
                case .downloadError:
                    message = String(localized: "Failed to download the episode", bundle: .module)
                }
                messageClient.presentError(message)
            }
        }
    }
}

private extension FeedScreen {
    func downloadState(id: Episode.ID) -> EpisodeDownloadState {
        downloadStates[id] ?? .notDownloaded
    }
    
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
