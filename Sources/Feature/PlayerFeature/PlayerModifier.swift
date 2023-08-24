import Extension
import SoundPlayerState
import SwiftUI

public extension View {
    func player() -> some View {
        modifier(PlayerModifier())
    }
}

struct PlayerModifier: ViewModifier {
    @Environment(SoundPlayerState.self) private var soundPlayerState
    
    @State private var isSheetModeOn: Bool = false
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                PlayerBannerView()
                    .onTapGesture {
                        isSheetModeOn = true
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
                    get: { soundPlayerState.state.isPlayingOrPausing && isSheetModeOn },
                    set: { _ in isSheetModeOn = false }
                )
            ) {
                PlayerSheetView()
            }
    }
}
