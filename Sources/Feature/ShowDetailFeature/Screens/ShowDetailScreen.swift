import ClipboardClient
import Components
import Database
import Dependencies
import Entity
import Extension
import MessageClient
import NavigationState
import RSSClient
import SwiftData
import SwiftUI

@MainActor
public struct ShowDetailScreen: View {
    private let feedURL: URL
    private let imageURL: URL
    private let title: String
    /// この画面においてエピソードのダウンロードや再生が可能かどうかを表す。
    /// 検索画面から遷移した場合は false になる。
    private let showsEpisodeActionButtons: Bool
    
    @State private var episodes: [EpisodeRecord]
    @State private var author: String?
    @State private var description: String?
    @State private var linkURL: URL?
    @State private var isFetchingShow: Bool = false
    @State private var downloadStates: [EpisodeRecord.ID: EpisodeDownloadState]? = nil
    
    @FetchRequest var showRecords: FetchedResults<ShowRecord>
    private var show: ShowRecord? { showRecords.first }
    
    @Environment(\.openURL) private var openURL
    @Environment(\.managedObjectContext) private var context
    
    @Dependency(\.clipboardClient) private var clipboardClient
    @Dependency(\.messageClient) private var messageClient
    @Dependency(\.rssClient) private var rssClient

    public init(args: ShowDetailInitArguments) {
        self.feedURL = args.feedURL
        self.imageURL = args.imageURL
        self.title = args.title
        self.showsEpisodeActionButtons = args.showsEpisodeActionButtons
        
        self._episodes = .init(initialValue: args.episodes)
        self._author = .init(initialValue: args.author)
        self._description = .init(initialValue: args.description)
        self._linkURL = .init(initialValue: args.linkURL)
        
        self._showRecords = ShowRecord.withFeedURL(feedURL)
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ShowHeaderView(
                    imageURL: imageURL,
                    title: title,
                    author: author,
                    description: description,
                    followed: show != nil,
                    isFetchingShow: isFetchingShow,
                    toggleFollowButtonTapped: { Task { await toggleFollow() } }
                )

                EpisodeDivider()

                if episodes.isEmpty {
                    ForEach(0..<10) { _ in
                        EpisodeRowView(
                            episode: .fixture,
                            showsPlayButton: showsEpisodeActionButtons,
                            showsImage: false
                        )
                        .redacted(reason: .placeholder)

                        EpisodeDivider()
                    }
                } else {
                    ForEach(episodes) { episode in
                        EpisodeRowView(
                            episode: episode,
                            showsPlayButton: showsEpisodeActionButtons,
                            showsImage: false
                        )

                        EpisodeDivider()
                    }
                }
            }
        }
        .padding(.horizontal)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        clipboardClient.copy(feedURL.absoluteString)
                        messageClient.presentSuccess(String(localized: "Copied", bundle: .module))
                    } label: {
                        Label(
                            title: { Text("Copy Feed URL", bundle: .module) },
                            icon: { Image(systemName: "doc") }
                        )
                    }
                    if let linkURL = linkURL {
                        Button {
                            openURL(linkURL)
                        } label: {
                            Label(
                                title: { Text("Open in Browser", bundle: .module) },
                                icon: { Image(systemName: "globe") }
                            )
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(title)
        .task {
            let reflectShow = { (show: ShowRecord) in
                author = show.author
                linkURL = show.linkURL
                description = show.showDescription
                episodes = show.episodes
            }
            
            if let show = show {
                reflectShow(show)
            }
            
            isFetchingShow = true
            defer { isFetchingShow = false }
            switch await rssClient.fetch(feedURL) {
            case .success(let show):
                reflectShow(show)
            case .failure(let error):
                let message: String
                switch error {
                case .invalidFeed:
                    message = String(localized: "Invalid RSS feed", bundle: .module)
                case .networkError(reason: let error):
                    message = error.localizedDescription
                }

                messageClient.presentError(message)
            }
        }
    }
}

private extension ShowDetailScreen {
    func downloadState(id: EpisodeRecord.ID) -> EpisodeDownloadState {
        guard let downloadStates else { return .notDownloaded }
        return downloadStates[id] ?? .notDownloaded
    }
    
    func toggleFollow() async {
        if showRecords.isEmpty {
            let showRecord = ShowRecord(
                context: context,
                title: title,
                description: description,
                author: author,
                feedURL: feedURL,
                imageURL: imageURL,
                linkURL: linkURL
            )
            for episode in self.episodes {
                let episode = EpisodeRecord(
                    context: context,
                    id: episode.id,
                    title: episode.title,
                    subtitle: episode.subtitle,
                    description: episode.episodeDescription,
                    duration: episode.duration,
                    soundURL: episode.soundURL,
                    publishedAt: episode.publishedAt
                )
                showRecord.addToEpisodes_(episode)
            }
            context.saveWithErrorHandling { _ in
                messageClient.presentError(String(localized: "Failed to follow the show", bundle: .module))
            }
        } else {
            for showRecord in showRecords {
                context.delete(showRecord)
            }
            context.saveWithErrorHandling { _ in
                messageClient.presentError(String(localized: "Failed to unfollow the show", bundle: .module))
            }
        }
    }
}
