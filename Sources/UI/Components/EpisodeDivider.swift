import SwiftUI

public struct EpisodeDivider: View {
    public init() {}

    public var body: some View {
        Divider()
            .frame(height: 0.5)
            .overlay { Color(.systemGray2) }
            .padding(.vertical, 8)
    }
}

#if DEBUG

#Preview {
    EpisodeDivider()
}

#endif
