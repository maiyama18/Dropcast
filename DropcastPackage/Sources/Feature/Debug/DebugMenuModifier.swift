import SwiftUI

struct DebugMenuModifier: ViewModifier {
    @State private var isPresented: Bool = false
    
    func body(content: Content) -> some View {
        #if DEBUG
        content
            .sheet(isPresented: $isPresented) {
                DebugMenuScreen()
                    .presentationDetents([.medium])
            }
            .onShake {
                if isPresented {
                    // If the DebugMenu failed to display because another sheet was already present at the last Shake,
                    // set isPresented back to false.
                    isPresented = false
                    Task {
                        isPresented = true
                    }
                } else {
                    isPresented = true
                }
            }
        #else
        content
        #endif
    }
}
