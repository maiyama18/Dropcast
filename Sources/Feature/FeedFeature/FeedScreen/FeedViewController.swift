import Combine
import SwiftUI

public final class FeedViewController: UIHostingController<FeedScreen> {
    private var cancellables: Set<AnyCancellable> = .init()

    public init() {
        let viewModel = FeedViewModel()
        super.init(rootView: FeedScreen(viewModel: viewModel))

        Task { [weak self] in
            for await event in viewModel.eventStream {
                guard let self else { return }
                switch event {
                }
            }
        }.store(in: &cancellables)
    }

    @MainActor dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
