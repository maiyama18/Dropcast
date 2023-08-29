//
//  PlayerBannerView.swift
//
//
//  Created by maiyama18 on 2023/08/01
//
//

import Database
import Formatter
import NukeUI
import SoundPlayerState
import SwiftUI

@MainActor
public struct PlayerBannerView: View {
    @Environment(SoundPlayerState.self) private var soundPlayerState
    
    public init() {}
    
    public var body: some View {
        switch soundPlayerState.state {
        case .notPlaying:
            EmptyView()
        case .pausing(let episode):
            bannerView(playing: false, episode: episode)
        case .playing(let episode):
            bannerView(playing: true, episode: episode)
        }
    }
    
    private func bannerView(playing: Bool, episode: EpisodeRecord) -> some View {
        HStack {
            LazyImage(url: episode.show?.imageURL) { state in
                if let image = state.image {
                    image
                } else {
                    Color.secondary
                        .opacity(0.3)
                }
            }
            .frame(width: 48, height: 48)
            .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(episode.title)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                
                HStack(spacing: 2) {
                    Text(formatEpisodeDuration(duration: TimeInterval(soundPlayerState.currentTimeInt ?? 0)))
                    Text("/")
                    Text(formatEpisodeDuration(duration: soundPlayerState.duration ?? 0))
                }
                .font(.footnote.monospacedDigit())
                .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 0)
            
            HStack {
                Button(action: { soundPlayerState.goBackward(seconds: 10) }) {
                    Image(systemName: "gobackward.10")
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                }
                
                if playing {
                    Button(action: {
                        soundPlayerState.pause(episode: episode)
                    }) {
                        Image(systemName: "play.fill")
                            .hidden()
                            .overlay {
                                Image(systemName: "pause.fill")
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                    }
                } else {
                    Button(action: {
                        do {
                            try soundPlayerState.startPlaying(episode: episode)
                        } catch {}
                    }) {
                        Image(systemName: "play.fill")
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                    }
                }
                
                Button(action: { soundPlayerState.goForward(seconds: 10) }) {
                    Image(systemName: "goforward.10")
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                }
            }
            .font(.title)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .overlay(alignment: .bottom) {
            ProgressView(
                value: Double(soundPlayerState.currentTimeInt ?? 0),
                total: soundPlayerState.duration ?? 0
            )
        }
    }
}
