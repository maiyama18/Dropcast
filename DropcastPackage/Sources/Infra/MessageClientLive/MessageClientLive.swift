import Dependencies
import Drops
import MessageClient
import UIKit

extension MessageClient {
    static let live: MessageClient = MessageClient(
        presentError: { title in
            Drops.hideAll()

            let drop = Drop(
                title: title,
                titleNumberOfLines: 2,
                icon: UIImage(systemName: "exclamationmark.circle")?
                    .withTintColor(.systemRed, renderingMode: .alwaysOriginal)
            )
            Drops.show(drop)
        }
    )
}

extension MessageClient: DependencyKey {
    public static let liveValue: MessageClient = .live
}
