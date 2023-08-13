import SoundPlayerState
import SwiftUI

struct PlayerSheetView: View {
    @Environment(SoundPlayerState.self) private var soundPlayerState
    
    var body: some View {
        Text("PlayerSheetView")
    }
}
