import SwiftUI

final class LicenseDetailViewController: UIHostingController<LicenseDetailScreen> {
    public init(licenseName: String, licenseText: String) {
        super.init(rootView: LicenseDetailScreen(licenseName: licenseName, licenseText: licenseText))
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
