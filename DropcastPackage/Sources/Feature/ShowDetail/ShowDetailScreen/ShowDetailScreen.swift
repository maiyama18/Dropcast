import ComposableArchitecture
import Entity
import SwiftUI

public struct ShowDetailScreen: View {
    let store: StoreOf<ShowDetailReducer>

    public init(store: StoreOf<ShowDetailReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                ShowHeaderView(
                    imageURL: viewStore.imageURL,
                    title: viewStore.title,
                    author: viewStore.author,
                    description: viewStore.description,
                    followed: viewStore.followed,
                    requestInFlight: viewStore.taskRequestInFlight
                )
                .padding()
            }
            .task {
                viewStore.send(.task)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {

                        } label: {
                            Label("Copy Feed URL", systemImage: "doc")
                        }
                        Button {

                        } label: {
                            Label("Open in Browser", systemImage: "globe")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ShowDetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ShowDetailScreen(
                store: .init(
                    initialState: .init(
                        feedURL: Show.fixtureRebuild.feedURL,
                        imageURL: Show.fixtureRebuild.imageURL,
                        title: Show.fixtureRebuild.title
                    ),
                    reducer: ShowDetailReducer()
                )
            )
        }
        .tint(.orange)
    }
}
