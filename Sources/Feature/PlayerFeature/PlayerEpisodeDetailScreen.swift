import Components
import Database
import NavigationState
import SwiftUI

struct PlayerEpisodeDetailScreen: View {
    @Environment(NavigationState.self) private var navigationState

    let episode: EpisodeRecord
    let episodeDescription: String

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(episode.publishedAt.formatted(date: .numeric, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(episode.title)
                    .font(.headline.bold())
                    .minimumScaleFactor(0.8)
                    .lineLimit(3)

                if let show = episode.show {
                    Button {
                        Task {
                            await navigationState.moveToShowDetail(
                                args: .init(
                                    feedURL: show.feedURL,
                                    imageURL: show.imageURL,
                                    title: show.title
                                )
                            )
                        }
                    } label: {
                        Text(show.title)
                            .font(.headline.weight(.regular))
                            .underline()
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            HTMLView(
                htmlBodyString: episodeDescription,
                contentBottomInset: 0
            )
        }
        .padding(24)
    }
}
