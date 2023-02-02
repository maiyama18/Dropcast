import Entity
import SwiftUI

struct ShowRowView: View {
    let show: SimpleShow

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: show.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.secondary
                    .opacity(0.3)
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
        VStack {
            ShowRowView(show: .init(iTunesShow: .fixtureStackOverflow))
            ShowRowView(show: .init(iTunesShow: .fixtureStacktrace))
            ShowRowView(show: .init(iTunesShow: .fixtureRebuild))
            ShowRowView(show: .init(iTunesShow: .fixtureNature))
            ShowRowView(show: .init(iTunesShow: .fixtureBilingualNews))
            ShowRowView(show: .init(iTunesShow: .fixtureFukabori))
//            ShowRowView(show: .init(iTunesShow: .fixtureSuperLongProperties))
        }
        .padding(.horizontal)
    }
}
