import Entity
import SwiftUI

struct ShowRowView: View {
    let show: Show

    var body: some View {
        HStack {
            AsyncImage(url: show.artworkLowQualityURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.secondary
            }
            .frame(width: 80, height: 80)

            VStack(alignment: .leading) {
                Text(show.showName)
                    .lineLimit(2)

                Text(show.artistName)
                    .lineLimit(2)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ShowRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ShowRowView(show: .fixtureStackOverflow)
            ShowRowView(show: .fixtureStacktrace)
            ShowRowView(show: .fixtureRebuild)
            ShowRowView(show: .fixtureNature)
            ShowRowView(show: .fixtureBilingualNews)
            ShowRowView(show: .fixtureFukabori)
            ShowRowView(show: .fixtureSuperLongProperties)
        }
        .padding(.horizontal)
    }
}
