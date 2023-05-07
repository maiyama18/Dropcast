import Entity
import NukeUI
import SwiftUI

struct ShowRowView: View {
    let show: SimpleShow

    var body: some View {
        HStack(spacing: 12) {
            LazyImage(url: show.imageURL) { state in
                if let image = state.image {
                    image
                } else {
                    Color.secondary
                        .opacity(0.3)
                }
            }
            .frame(width: 72, height: 72)
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(show.title)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if let author = show.author {
                    Text(author)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ShowRowView_Previews: PreviewProvider {
    static var previews: some View {
        let shows: [SimpleShow] = [
            ITunesShow.fixtureStackOverflow,
            ITunesShow.fixtureRebuild,
            ITunesShow.fixtureNature,
            ITunesShow.fixtureBilingualNews,
            ITunesShow.fixtureFukabori,
            ITunesShow.fixtureStacktrace,
            ITunesShow.fixtureSuperLongProperties,
        ].map { .init(iTunesShow: $0) }

        List {
            ForEach(shows) { show in
                ShowRowView(show: show)
            }
        }
        .listStyle(.plain)
    }
}
