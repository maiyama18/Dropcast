import NukeUI
import SoundPlayerState
import SwiftUI

struct PlayerSheet: View {
    @Environment(SoundPlayerState.self) private var soundPlayerState

    @State private var backgroundRotationAngle: Angle = .degrees(Double.random(in: 0...360))

    var body: some View {
        TabView {
            PlayerMainScreen()

            if let episode = soundPlayerState.state.playingEpisode,
               let episodeDescription = episode.episodeDescription {
                PlayerEpisodeDetailScreen(episode: episode, episodeDescription: episodeDescription)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .presentationBackground {
            if let episode = soundPlayerState.state.playingEpisode,
               let showImageURL = episode.show?.imageURL {
                LazyImage(url: showImageURL) { state in
                    if let image = state.image {
                        image
                    } else {
                        Color.secondary
                            .opacity(0.3)
                    }
                }
                .aspectRatio(contentMode: .fill)
                .rotationEffect(backgroundRotationAngle)
                .overlay(Color(.systemBackground).opacity(0.6))
                .overlay(.ultraThinMaterial)
            }
        }
    }
}
