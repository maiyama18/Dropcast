#if DEBUG
import DebugMenu
import UIKit

public func installDebugMenu(windowScene: UIWindowScene) {
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
