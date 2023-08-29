import Components
import Database
import Extension
import Formatter
import NavigationState
import NukeUI
import SwiftUI
import WebKit

@MainActor
public struct EpisodeDetailScreen: View {
    private let episode: EpisodeRecord
    
    @Environment(NavigationState.self) private var navigationState
    @Environment(\.playerBannerHeight) private var playerBannerHeight
    
    public init(episode: EpisodeRecord) {
        self.episode = episode
    }
    
    public var body: some View {
        VStack {
            header
            
            if let description = episode.episodeDescription {
                Divider()
                
                HTMLView(htmlBodyString: description, contentBottomInset: playerBannerHeight)
            }
        }
        .padding(.horizontal)
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                EpisodeActionButton(episode: episode)
            }
        }
    }
    
    private var header: some View {
        HStack(alignment: .top) {
            if let showImageURL = episode.show?.imageURL {
                LazyImage(url: showImageURL) { state in
                    if let image = state.image {
                        image
                    } else {
                        Color.secondary
                            .opacity(0.3)
                    }
                }
                .frame(width: 84, height: 84)
                .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 0) {
                    Text(episode.publishedAt.formatted(date: .numeric, time: .omitted))
                    Text("・")
                    Text(formatEpisodeDuration(duration: episode.duration))
                }
                .font(.footnote.monospacedDigit())
                
                Text(episode.title)
                    .font(.headline.bold())
                    .lineLimit(3)
                
                if let show = episode.show {
                    Button(action: {
                        Task {
                            await navigationState.moveToShowDetail(
                                args: .init(
                                    feedURL: show.feedURL,
                                    imageURL: show.imageURL,
                                    title: show.title
                                )
                            )
                        }
                    }) {
                        Text(show.title)
                    }
                    .font(.headline.weight(.regular))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    EpisodeDetailScreen(
        episode: .fixture(
            context: PersistentProvider.inMemory.viewContext
        )
    )
}
