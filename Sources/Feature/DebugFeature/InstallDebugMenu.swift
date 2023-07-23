#if DEBUG
import DebugMenu
import SwiftUI

@MainActor
public func installDebugMenu() {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
        return
    }

    DebugMenu.install(
        windowScene: windowScene,
        items: [
            AppInfoDebugItem(),
            CopySoundFilesRootPathItem(),
            ViewControllerDebugItem<UIHostingController<DebugLogScreen>>(title: "See Debug Log") { _ in .init(rootView: DebugLogScreen()) },
        ],
        options: [.launchIcon(.init(initialPosition: .trailing))]
    )
}
#endif
