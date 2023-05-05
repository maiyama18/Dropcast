import Combine
import Entity
import SwiftUI

public final class ShowDetailViewController: UIHostingController<ShowDetailScreen> {
    
    private var cancellables: Set<AnyCancellable> = .init()
    
    public init(
        showsEpisodeActionButtons: Bool,
        feedURL: URL,
        imageURL: URL,
        title: String,
        episodes: [Episode] = [],
        author: String? = nil,
        description: String? = nil,
        linkURL: URL? = nil,
        followed: Bool? = nil
    ) {
        let viewModel = ShowDetailViewModel(
            feedURL: feedURL,
            imageURL: imageURL,
            title: title,
            episodes: episodes,
            author: author,
            description: description,
            linkURL: linkURL,
            followed: followed
        )
        super.init(
            rootView: ShowDetailScreen(
                viewModel: viewModel,
                showsEpisodeActionButtons: showsEpisodeActionButtons
            )
        )
        
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

