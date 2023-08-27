import Database
import Entity
import Formatter
import NukeUI
import SwiftUI

@MainActor
public struct EpisodeRowView: View {
    var episode: EpisodeRecord
    var showsImage: Bool
    
    public init(
        episode: EpisodeRecord,
        showsImage: Bool
    ) {
        self.episode = episode
        self.showsImage = showsImage
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if showsImage, let showImageURL = episode.show?.imageURL {
                LazyImage(url: showImageURL) { state in
                    if let image = state.image {
                        image
                    } else {
                        Color.secondary
                            .opacity(0.3)
                    }
                }
                .frame(width: 64, height: 64)
                .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 0) {
                    Text(episode.publishedAt.formatted(date: .numeric, time: .omitted))
                    Text("・")
                    Text(formatEpisodeDuration(duration: episode.duration))
                }
                .font(.footnote.monospacedDigit())
                
                Group {
                    if episode.playingState?.isCompleted == true {
                        Text(Image(systemName: "checkmark.circle.fill"))
                            + Text(" ")
                            + Text(episode.title)
                    } else {
                        Text(episode.title)
                    }
                }
                .font(.body.bold())
                .lineLimit(2)
                
                if let subtitle = episode.subtitle {
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
                
                HStack(spacing: 12) {
                    EpisodeActionButton(episode: episode)
                        .tint(.accentColor)
                    
                    Spacer()
                    
                    Button {
                        print("misc")
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    
                    Button {
                        print("misc")
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                .font(.title)
                .tint(.accentColor)
            }
        }
        .multilineTextAlignment(.leading)
        .tint(.primary)
    }
}
