import Combine
import SwiftUI

final class ShowSearchViewController: UIHostingController<ShowSearchScreen> {
    private var cancellables: Set<AnyCancellable> = .init()
    
    init() {
        let viewModel = ShowSearchViewModel()
        super.init(rootView: ShowSearchScreen(viewModel: viewModel))
        
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
