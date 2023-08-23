import CoreData
import Database
import Formatter
import NukeUI
import SoundPlayerState
import SwiftUI

@MainActor
struct PlayerSheetView: View {
    @Environment(SoundPlayerState.self) private var soundPlayerState
    @State private var backgroundRotationAngle: Angle = .degrees(Double.random(in: 0...360))
    @State private var imageScale: Double = 0.2
    
    var body: some View {
        switch soundPlayerState.state {
        case .notPlaying:
            Color.clear
                .background(.ultraThinMaterial)
        case .pausing(let episode):
            sheetView(playing: false, episode: episode)
        case .playing(let episode):
            sheetView(playing: true, episode: episode)
        }
    }
    
    private func sheetView(playing: Bool, episode: EpisodeRecord) -> some View {
        VStack {
            Spacer(minLength: 8)
            
            lazyImage(show: episode.show)
                .cornerRadius(8)
                .aspectRatio(contentMode: .fit)
                .scaleEffect(imageScale, anchor: .bottomLeading)
                .animation(.default, value: imageScale)
                .onAppear {
                    imageScale = 1
                }
            
            Spacer().frame(height: 16)
            
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
            
            Spacer(minLength: 8)
            
            progressView
            
            actionButtonsView(playing: playing, episode: episode)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .presentationBackground {
            lazyImage(show: episode.show)
                .aspectRatio(contentMode: .fill)
                .rotationEffect(backgroundRotationAngle)
                .overlay(Color(.systemBackground).opacity(0.6))
                .overlay(.ultraThinMaterial)
        }
    }
    
    private var progressView: some View {
        VStack(spacing: 0) {
            Slider(
                value: .init(
                    get: { Double(soundPlayerState.currentTimeInt ?? 0) },
                    set: { soundPlayerState.move(to: $0) }
                ),
                in: 0...(soundPlayerState.duration ?? 0)
            )
            
            HStack {
                Text(
                    formatEpisodeDuration(
                        duration: Double(soundPlayerState.currentTimeInt ?? 0)
                    )
                )
                
                Spacer(minLength: 0)
                
                Text(
                    "-" +
                    formatEpisodeDuration(
                        duration: Double(soundPlayerState.duration ?? 0) - Double(soundPlayerState.currentTimeInt ?? 0)
                    )
                )
            }
            .font(.caption.monospacedDigit())
            .foregroundStyle(.secondary)
        }
    }
    
    private func actionButtonsView(playing: Bool, episode: EpisodeRecord) -> some View {
        HStack {
            Group {
                Text(SoundPlayerState.SpeedRate._1_75.formatted)
                    .hidden()
                    .overlay {
                        Menu(soundPlayerState.speedRate.formatted) {
                            ForEach(SoundPlayerState.SpeedRate.allCases, id: \.rawValue) { rate in
                                Button {
                                    soundPlayerState.speedRate = rate
                                } label: {
                                    Text(rate.formatted)
                                        .padding(.vertical)
                                }
                            }
                        }
                    }
                    .font(.body.monospacedDigit())
                    .padding(.vertical)
                
                Button(action: { soundPlayerState.goBackward(seconds: 10) }) {
                    Image(systemName: "gobackward.10")
                        .padding(.vertical)
                }
                
                if playing {
                    Button(action: {
                        soundPlayerState.pause(episode: episode)
                    }) {
                        Image(systemName: "play.fill")
                            .hidden()
                            .overlay {
                                Image(systemName: "pause.fill")
                                    .padding(.vertical)
                            }
                            .padding(.vertical)
                    }
                } else {
                    Button(action: {
                        do {
                            try soundPlayerState.startPlaying(episode: episode)
                        } catch {}
                    }) {
                        Image(systemName: "play.fill")
                            .padding(.vertical)
                    }
                }
                
                Button(action: { soundPlayerState.goForward(seconds: 10) }) {
                    Image(systemName: "goforward.10")
                        .padding(.vertical)
                }
                
                Text(SoundPlayerState.SpeedRate._1_75.formatted)
                    .hidden()
                    .font(.body.monospacedDigit())
            }
            .frame(maxWidth: .infinity)
        }
        .font(.largeTitle)
        .tint(.primary)
        .frame(maxWidth: .infinity)
        
    }
    
    private func lazyImage(show: ShowRecord?) -> some View {
        LazyImage(url: show?.imageURL) { state in
            if let image = state.image {
                image
            } else {
                Color.secondary
                    .opacity(0.3)
            }
        }
    }
}

#Preview {
    let playerState: SoundPlayerState = {
        let playerState = SoundPlayerState(
            context: PersistentProvider.preview.viewContext
        )
        playerState.state = .playing(episode: .fixture(context: PersistentProvider.preview.viewContext))
        return playerState
    }()
    
    return Text("Preview")
        .sheet(isPresented: .constant(true)) {
            PlayerSheetView()
                .environment(playerState)
                .tint(.orange)
        }
}
