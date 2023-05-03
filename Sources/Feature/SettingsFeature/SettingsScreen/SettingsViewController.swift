import Combine
import SwiftUI

public final class SettingsViewController: UIHostingController<SettingsScreen> {
    private var cancellables: Set<AnyCancellable> = .init()
    
    public init() {
        let viewModel = SettingsViewModel()
        super.init(rootView: SettingsScreen(viewModel: viewModel))
        
        Task { [weak self] in
            for await event in viewModel.eventStream {
                guard let self else { return }
                switch event {
                case .pushLicenses:
                    self.navigationController?.pushViewController(LicensesViewController(), animated: true)
                }
            }
        }
        .store(in: &cancellables)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
