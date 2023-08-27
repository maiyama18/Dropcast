import Components
import Database
import SwiftUI

struct PlayerEpisodeDetailScreen: View {
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
                
                Text(episode.show?.title ?? "")
                    .font(.headline.weight(.regular))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            HTMLView(
                htmlBodyString: episodeDescription,
                contentBottomInset: 0
            )
        }
        .padding(16)
        .background(Material.ultraThin)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .padding(16)
    }
}
