import Dependencies
import ScreenProvider
import ShowDetailFeature
import SwiftUI

extension ScreenProvider {
    public static let live: ScreenProvider = ScreenProvider(
        provideShowDetailScreen: { args in
            AnyView(
                ShowDetailScreen(
                    feedURL: args.feedURL,
                    imageURL: args.imageURL,
                    title: args.title,
                    author: args.author,
                    description: args.description,
                    linkURL: args.linkURL
                )
            )
        }
    )
}

extension ScreenProvider: DependencyKey {
    public static let liveValue: ScreenProvider = .live
}
