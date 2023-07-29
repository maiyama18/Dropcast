import DebugMenu
import SwiftUI

extension View {
    public func installDebugMenu() -> some View {
        modifier(InstallDebugMenuModifier())
    }
}

struct InstallDebugMenuModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if DEBUG
        content
            .debugMenu(
                debuggerItems: [
                    AppInfoDebugItem(),
                    CopySoundFilesRootPathItem(),
                    ViewControllerDebugItem<UIHostingController<DebugLogScreen>>(title: "See Debug Log") { _ in .init(rootView: DebugLogScreen()) },
                ],
                options: [.launchIcon(.init(initialPosition: .trailing))]
            )
        #else
        content
        #endif
    }
}
