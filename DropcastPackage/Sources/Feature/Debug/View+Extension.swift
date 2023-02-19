import SwiftUI

extension View {
    public func debugMenu() -> some View {
        modifier(DebugMenuModifier())
    }
    
}
