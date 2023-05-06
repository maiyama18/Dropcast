import Combine
import Extension
import SwiftUI

final class LicensesViewController: UIHostingController<LicensesScreen> {
    private var cancellables: Set<AnyCancellable> = .init()

    init() {
        let viewModel = LicensesViewModel()
        super.init(rootView: LicensesScreen(viewModel: viewModel))

        Task { [weak self] in
            for await event in viewModel.eventStream {
                guard let self else { return }
                switch event {
                case .pushLicenseDetail(let licenseName, let licenseText):
                    self.navigationController?.pushViewController(
                        LicenseDetailViewController(licenseName: licenseName, licenseText: licenseText),
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
