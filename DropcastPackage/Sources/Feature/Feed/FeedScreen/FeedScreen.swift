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
                            emptyView(onButtonTapped: {
                                viewStore.send(.followShowsButtonTapped)
                            })
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    ForEach(episodes) { episode in
                                        EpisodeRowView(
                                            episode: episode,
                                            downloadState: viewStore.state.downloadState(id: episode.id),
                                            showsImage: true,
                                            onDownloadButtonTapped: {
                                                viewStore.send(.downloadEpisodeButtonTapped(episode: episode))
                                            }
                                        )
                                        
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
                .navigationTitle(L10n.feed)
            }
            .task {
                viewStore.send(.task)
            }
        }
    }
    
    @ViewBuilder
    private func emptyView(onButtonTapped: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            Image(systemName: "face.dashed")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            
            Spacer()
                .frame(height: 8)
            
            Text(L10n.noFeed)
                .font(.title3.bold())
                .foregroundStyle(.secondary)
            
            Spacer()
                .frame(height: 16)
            
            Button(L10n.followShows) {
                onButtonTapped()
            }
            .tint(.orange)
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }
}

struct FeedScreen_Previews: PreviewProvider {
    static var previews: some View {
        FeedScreen(
            store: StoreOf<FeedReducer>(
                initialState: FeedReducer.State(),
                reducer: withDependencies({
                    _ = $0.databaseClient.followShow(.fixtureRebuild)
                    _ = $0.databaseClient.followShow(.fixtureSwiftBySundell)
                }) {
                    FeedReducer()
                }
            )
        )
        .tint(.orange)
    }
}
