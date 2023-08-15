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
    private let initialImageURL: URL
    private let initialTitle: String
    
    @State private var isFetchingShow: Bool = false
    @State private var downloadStates: [EpisodeRecord.ID: EpisodeDownloadState]? = nil
    
    @FetchRequest var showRecords: FetchedResults<ShowRecord>
    private var show: ShowRecord? { showRecords.first }
    
    @FetchRequest var episodeRecords: FetchedResults<EpisodeRecord>
    
    @Environment(\.openURL) private var openURL
    @Environment(\.managedObjectContext) private var context
    
    @Dependency(\.clipboardClient) private var clipboardClient
    @Dependency(\.messageClient) private var messageClient
    @Dependency(\.rssClient) private var rssClient

    public init(args: ShowDetailInitArguments) {
        self.feedURL = args.feedURL
        self.initialImageURL = args.imageURL
        self.initialTitle = args.title
        
        self._showRecords = ShowRecord.withFeedURL(feedURL)
        self._episodeRecords = FetchRequest(fetchRequest: EpisodeRecord.withShowFeedURL(feedURL))
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ShowHeaderView(
                    imageURL: show?.imageURL ?? initialImageURL,
                    title: show?.title ?? initialTitle,
                    author: show?.author,
                    description: show?.showDescription,
                    followed: show?.followed ?? false,
                    isFetchingShow: isFetchingShow,
                    toggleFollowButtonTapped: {
                        guard let show else { return }
                        do {
                            try show.toggleFollow()
                        } catch {
                            messageClient.presentError(String(localized: "Unexpected error occurred", bundle: .module))
                        }
                    }
                )

                EpisodeDivider()

                if episodeRecords.isEmpty {
                    ForEach(0..<10) { _ in
                        EpisodeRowView(
                            episode: .fixture(context: context),
                            showsPlayButton: true,
                            showsImage: false
                        )
                        .redacted(reason: .placeholder)

                        EpisodeDivider()
                    }
                } else {
                    ForEach(episodeRecords, id: \.objectID) { episode in
                        EpisodeRowView(
                            episode: episode,
                            showsPlayButton: true,
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
                    if let linkURL = show?.linkURL {
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
        .navigationTitle(show?.title ?? "")
        .task {
            isFetchingShow = true
            defer { isFetchingShow = false }
            
            do {
                let rssShow = try await rssClient.fetch(feedURL).get()
                if let show {
                    let existingEpisodeIDs = Set(show.episodes.map(\.id))
                    for rssEpisode in rssShow.episodes where !existingEpisodeIDs.contains(rssEpisode.id) {
                        show.addToEpisodes_(rssEpisode.toModel(context: context))
                    }
                    try show.save()
                } else {
                    try rssShow.toModel(context: context).save()
                }
            } catch {
                messageClient.presentError(String(localized: "Failed to fetch show information", bundle: .module))
            }
        }
    }
}

private extension ShowDetailScreen {
    func downloadState(id: EpisodeRecord.ID) -> EpisodeDownloadState {
        guard let downloadStates else { return .notDownloaded }
        return downloadStates[id] ?? .notDownloaded
    }
}
