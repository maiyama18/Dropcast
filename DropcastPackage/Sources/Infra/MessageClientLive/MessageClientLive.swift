import Dependencies
import Drops
import MessageClient
import UIKit

extension MessageClient {
    static var live: MessageClient {
        @Sendable
        func present(title: String, iconSystemName: String, iconColor: UIColor) {
                Drops.hideAll()

                let drop = Drop(
                    title: title,
                    titleNumberOfLines: 2,
                    icon: UIImage(systemName: iconSystemName)?
                        .withTintColor(iconColor, renderingMode: .alwaysOriginal)
                )
                Drops.show(drop)
        }

        return MessageClient(
            presentError: { title in
                present(title: title, iconSystemName: "exclamationmark.circle", iconColor: .systemRed)
            },
            presentSuccess: { title in
                present(title: title, iconSystemName: "checkmark.circle", iconColor: .systemTeal)
            }
        )
    }
}

extension MessageClient: DependencyKey {
    public static let liveValue: MessageClient = .live
}
