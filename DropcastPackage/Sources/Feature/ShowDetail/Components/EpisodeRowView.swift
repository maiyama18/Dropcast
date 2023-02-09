import Entity
import Formatter
import SwiftUI

struct EpisodeRowView: View {
    var episode: Episode

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 0) {
                Text(episode.publishedAt.formatted(date: .numeric, time: .omitted))
                Text("・")
                Text(formatEpisodeDuration(duration: episode.duration))
            }
            .font(.footnote.monospacedDigit())

            Text(episode.title)
                .font(.body.bold())

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

struct EpisodeRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ForEach(Show.fixtureRebuild.episodes) { episode in
                EpisodeRowView(episode: episode)
            }

            ForEach(Show.fixtureプログラム雑談.episodes) { episode in
                EpisodeRowView(episode: episode)
            }
        }
        .listStyle(.plain)
    }
}
