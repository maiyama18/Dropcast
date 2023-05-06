import Combine
import Dependencies
import SwiftUI
import ViewFactory

public final class ShowListViewController: UIHostingController<ShowListScreen> {
    private var cancellables: Set<AnyCancellable> = .init()
    
    @Dependency(\.viewFactory) private var viewFactory
    
    public init() {
        let viewModel = ShowListViewModel()
        super.init(rootView: ShowListScreen(viewModel: viewModel))
        
        Task { [weak self] in
            for await event in viewModel.eventStream {
                guard let self else { return }
                switch event {
                case .presentShowSearch:
                    present(
                        UINavigationController(rootViewController: ShowSearchViewController()),
                        animated: true
                    )
                case .pushShowDetail(let show):
                    navigationController?.pushViewController(
                        viewFactory.makeShowDetail(
                            .init(
                                showsEpisodeActionButtons: true,
                                feedURL: show.feedURL,
                                imageURL: show.imageURL,
                                title: show.title,
                                episodes: show.episodes,
                                author: show.author,
                                description: show.description,
                                linkURL: show.linkURL,
                                followed: true
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
    
    public func presentShowSearch() {
        Task {
            await rootView.viewModel.handle(action: .tapAddButton)
        }
    }
}
