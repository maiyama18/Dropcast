import SwiftUI

public struct ProgressSystemImage: View {
    @Environment(\.font) var font

    var systemName: String
    var progress: Double
    var onColor: Color
    var offColor: Color

    public init(systemName: String, progress: Double, onColor: Color, offColor: Color) {
        self.systemName = systemName
        self.progress = progress
        self.onColor = onColor
        self.offColor = offColor
    }

    public var body: some View {
        Image(systemName: systemName)
            .font(font)
            .hidden()
            .overlay {
                Rectangle()
                    .fill(
                        AngularGradient(
                            stops: [
                                .init(color: onColor, location: 0),
                                .init(color: onColor, location: progress),
                                .init(color: offColor, location: progress),
                                .init(color: offColor, location: 1),
                            ],
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        )
                    )
                    .mask {
                        Image(systemName: systemName)
                            .font(font)
                    }
            }
    }
}

#if DEBUG

#Preview {
    
VStack {
    HStack {
        ForEach([0, 0.2, 0.4, 0.6, 0.8, 1], id: \.self) { progress in
            ProgressSystemImage(
                systemName: "play.circle",
                progress: progress,
                onColor: .orange,
                offColor: .gray.opacity(0.3)
            )
        }
    }
    .font(.title)

    HStack {
        ForEach([0, 0.2, 0.4, 0.6, 0.8, 1], id: \.self) { progress in
            ProgressSystemImage(
                systemName: "pause.circle",
                progress: progress,
                onColor: .teal,
                offColor: .teal.opacity(0.2)
            )
        }
    }
    .font(.largeTitle)
}
    
}

#endif
