import Entity
import Formatter
import NukeUI
import SwiftUI

public struct EpisodeRowView: View {
    var episode: Episode
    var showsImage: Bool

    public init(episode: Episode, showsImage: Bool) {
        self.episode = episode
        self.showsImage = showsImage
    }

    public var body: some View {
        HStack(alignment: .top) {
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
                        print("play")
                    } label: {
                        Image(systemName: "play.circle")
                            .font(.title)
                    }

                    Spacer()

                    Button {
                        print("mark as played")
                    } label: {
                        Image(systemName: "checkmark.circle")
                            .font(.title)
                    }

                    Button {
                        print("add to playlist")
                    } label: {
                        Image(systemName: "plus.circle")
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
                    EpisodeRowView(episode: episode, showsImage: true)

                    EpisodeDivider()
                }

                ForEach(Show.fixtureプログラム雑談.episodes) { episode in
                    EpisodeRowView(episode: episode, showsImage: false)

                    EpisodeDivider()
                }
            }
            .padding(.horizontal)
            .tint(.orange)
        }
    }
}
