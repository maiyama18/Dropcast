import Combine
import SwiftUI

final class DebugLogViewController: UIHostingController<DebugLogScreen> {
    init() {
        let viewModel = DebugLogViewModel()
        super.init(rootView: DebugLogScreen(viewModel: viewModel))
    }

    @MainActor dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
