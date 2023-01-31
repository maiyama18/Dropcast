import Entity
import SwiftUI

struct ShowRowView: View {
    let show: FollowShowsReducer.State.Show

    var body: some View {
        HStack {
            AsyncImage(url: show.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.secondary
            }
            .frame(width: 80, height: 80)

            VStack(alignment: .leading) {
                Text(show.title)
                    .lineLimit(2)

                if let author = show.author {
                    Text(author)
                        .lineLimit(2)
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
            ShowRowView(show: .init(iTunesShow: .fixtureSuperLongProperties))
        }
        .padding(.horizontal)
    }
}
