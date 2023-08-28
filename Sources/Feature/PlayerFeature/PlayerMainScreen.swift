import CoreData
import Database
import Dependencies
import Formatter
import NavigationState
import NukeUI
import PodcastChapterExtractUseCase
import SoundPlayerState
import SwiftUI

@MainActor
struct PlayerMainScreen: View {
    @Environment(SoundPlayerState.self) private var soundPlayerState
    @Environment(NavigationState.self) private var navigationState
    
    @State private var imageScale: Double = 0.2
    @State private var chaptersMenuPresented: Bool = false
    
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
            
            Spacer(minLength: 8)
            
            Text(soundPlayerState.currentChapter?.title ?? " ")
                .foregroundStyle(.secondary)
                .font(.subheadline.bold())
            
            progressView
            
            actionButtonsView(playing: playing, episode: episode)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            if chaptersMenuPresented {
                chaptersMenu
                    .transition(.opacity)
            }
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
                        Menu {
                            ForEach(SoundPlayerState.SpeedRate.allCases, id: \.rawValue) { rate in
                                Button {
                                    soundPlayerState.speedRate = rate
                                } label: {
                                    Text(rate.formatted)
                                        .padding(.vertical)
                                }
                            }
                        } label: {
                            Text(soundPlayerState.speedRate.formatted)
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
                    .overlay {
                        if soundPlayerState.currentChapter != nil {
                            Button {
                                withAnimation {
                                    chaptersMenuPresented = true
                                }
                            } label: {
                                Image(systemName: "list.dash")
                                    .padding(.vertical)
                            }
                        }
                    }
            }
            .frame(maxWidth: .infinity)
        }
        .font(.largeTitle)
        .tint(.primary)
        .frame(maxWidth: .infinity)
    }
    
    private var chaptersMenu: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        chaptersMenuPresented = false
                    }
                }
            
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack {
                        ForEach(soundPlayerState.chapters, id: \.startsAt) { chapter in
                            Button {
                                soundPlayerState.goToChapter(chapter: chapter)
                            } label: {
                                HStack {
                                    Text(chapter.title)
                                    
                                    Spacer()
                                    
                                    Text(formatEpisodeDuration(duration: chapter.duration))
                                        .foregroundStyle(.secondary)
                                        .font(.callout.monospacedDigit())
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 8)
                                .background {
                                    if chapter == soundPlayerState.currentChapter {
                                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                                            .fill(Color(.systemGroupedBackground))
                                            .overlay {
                                                HStack(spacing: 0) {
                                                    GeometryReader { proxy in
                                                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                                                            .fill(Color.accentColor.opacity(0.5))
                                                            .frame(width: proxy.size.width * soundPlayerState.currentChapterProgress)
                                                    }
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                    }
                                }
                                .padding(.horizontal, 8)
                            }
                        }
                        .tint(.primary)
                    }
                    .padding(.vertical, 8)
                }
                .onAppear {
                    if let currentChapter = soundPlayerState.currentChapter {
                        proxy.scrollTo(currentChapter.startsAt, anchor: .center)
                    }
                }
            }
            .background(Material.regular, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .padding(.horizontal, 36)
            .frame(height: 400)
        }
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
            context: PersistentProvider.inMemory.viewContext
        )
        playerState.state = .playing(episode: .fixture(context: PersistentProvider.inMemory.viewContext))
        return playerState
    }()
    
    return Text("Preview")
        .sheet(isPresented: .constant(true)) {
            PlayerMainScreen()
                .environment(playerState)
                .tint(.orange)
        }
}
