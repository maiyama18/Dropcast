#if DEBUG
import DebugMenu
import UIKit

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
            ViewControllerDebugItem<DebugLogViewController>(title: "See Debug Log") { $0.init() },
        ],
        options: [.launchIcon(.init(initialPosition: .trailing))]
    )
}
#endif
