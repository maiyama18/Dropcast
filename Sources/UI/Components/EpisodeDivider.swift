import SwiftUI

public struct EpisodeDivider: View {
    public init() {}

    public var body: some View {
        Divider()
            .frame(height: 0.75)
            .overlay { Color.secondary }
            .padding(.vertical, 8)
    }
}

struct EpisodeDivider_Previews: PreviewProvider {
    static var previews: some View {
        EpisodeDivider()
    }
}
