import Extension
import NavigationState
import SoundPlayerState
import SwiftUI

public extension View {
    func player() -> some View {
        modifier(PlayerModifier())
    }
}

struct PlayerModifier: ViewModifier {
    @Environment(SoundPlayerState.self) private var soundPlayerState
    @Environment(NavigationState.self) private var navigationState

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                PlayerBannerView()
                    .onTapGesture {
                        navigationState.playerSheetModeOn = true
                    }
                    .background {
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: PlayerBannerHeightKey.self, value: proxy.size.height)
                        }
                    }
            }
            .sheet(
                isPresented: .init(
                    get: { soundPlayerState.state.isPlayingOrPausing && navigationState.playerSheetModeOn },
                    set: { _ in navigationState.playerSheetModeOn = false }
                )
            ) {
                PlayerSheet()
            }
    }
}
