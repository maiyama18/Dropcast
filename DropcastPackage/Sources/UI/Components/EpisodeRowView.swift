import Entity
import Formatter
import NukeUI
import SwiftUI

public struct EpisodeRowView: View {
    var episode: Episode
    var showsImage: Bool
    var onDownloadButtonTapped: () -> Void

    public init(episode: Episode, showsImage: Bool, onDownloadButtonTapped: @escaping () -> Void) {
        self.episode = episode
        self.showsImage = showsImage
        self.onDownloadButtonTapped = onDownloadButtonTapped
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if showsImage {
                LazyImage(url: episode.showImageURL) { state in
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

                Text(episode.title)
                    .font(.body.bold())
                    .lineLimit(2)

                if let subtitle = episode.subtitle {
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }

                HStack(spacing: 12) {
                    Button {
                        onDownloadButtonTapped()
                    } label: {
                        Image(systemName: "arrow.down.to.line.circle")
                            .font(.title)
                    }
                    
                    Spacer()
                    
                    Button {
                        print("misc")
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.title)
                    }

                    Button {
                        print("misc")
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title)
                    }
                }
            }
        }
    }
}

struct EpisodeRowView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            LazyVStack {
                ForEach(Show.fixtureRebuild.episodes) { episode in
                    EpisodeRowView(
                        episode: episode,
                        showsImage: true,
                        onDownloadButtonTapped: {}
                    )

                    EpisodeDivider()
                }

                ForEach(Show.fixtureプログラム雑談.episodes) { episode in
                    EpisodeRowView(
                        episode: episode,
                        showsImage: false,
                        onDownloadButtonTapped: {}
                    )

                    EpisodeDivider()
                }
            }
            .padding(.horizontal)
            .tint(.orange)
        }
    }
}
