import Combine
import Dependencies
import SwiftUI
import ViewFactory

final class ShowSearchViewController: UIHostingController<ShowSearchScreen> {
    private var cancellables: Set<AnyCancellable> = .init()
    
    @Dependency(\.viewFactory) private var viewFactory
    
    init() {
        let viewModel = ShowSearchViewModel()
        super.init(rootView: ShowSearchScreen(viewModel: viewModel))
        
        Task { [weak self] in
            for await event in viewModel.eventStream {
                guard let self else { return }
                switch event {
                case .pushShowDetail(let show):
                    self.navigationController?.pushViewController(
                        viewFactory.makeShowDetail(
                            .init(
                                showsEpisodeActionButtons: false,
                                feedURL: show.feedURL,
                                imageURL: show.artworkURL,
                                title: show.showName,
                                episodes: []
                            )
                        ),
                        animated: true
                    )
                }
            }
        }.store(in: &cancellables)
    }
    
    @MainActor dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
