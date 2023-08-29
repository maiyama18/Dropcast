import Entity
import NukeUI
import SwiftUI

struct ShowRowView: View {
    let feedURL: URL
    let imageURL: URL
    let title: String
    let author: String?
    
    var body: some View {
        HStack(spacing: 12) {
            LazyImage(url: imageURL) { state in
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
                Text(title)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if let author {
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
