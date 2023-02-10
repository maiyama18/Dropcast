import Components
import ComposableArchitecture
import DatabaseClient
import Entity
import SwiftUI

public struct FeedScreen: View {
    let store: StoreOf<FeedReducer>

    public init(store: StoreOf<FeedReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                Group {
                    if let episodes = viewStore.episodes {
                        if episodes.isEmpty {
                            Text("Empty")
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    ForEach(episodes) { episode in
                                        EpisodeRowView(episode: episode, showsImage: true)

                                        EpisodeDivider()
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    } else {
                        ProgressView()
                            .scaleEffect(2)
                    }
                }
                .navigationTitle("Feed")
            }
            .task {
                viewStore.send(.task)
            }
        }
    }
}

struct FeedScreen_Previews: PreviewProvider {
    static var previews: some View {
        FeedScreen(
            store: StoreOf<FeedReducer>(
                initialState: FeedReducer.State(),
                reducer: withDependencies({
                    try? $0.databaseClient.followShow(.fixtureRebuild)
                    try? $0.databaseClient.followShow(.fixtureSwiftBySundell)
                }) {
                    FeedReducer()
                }
            )
        )
        .tint(.orange)
    }
}
