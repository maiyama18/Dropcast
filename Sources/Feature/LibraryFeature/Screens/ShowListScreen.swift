import CoreData
import Database
import Dependencies
import IdentifiedCollections
import NavigationState
import ShowDetailFeature
import SwiftUI

@MainActor
public struct ShowListScreen: View {
    // TODO: ソートする
    @FetchRequest<ShowRecord>(sortDescriptors: []) private var showRecords: FetchedResults<ShowRecord>
    
    private var shows: [ShowRecord] {
        showRecords.sorted(by: { $0.title > $1.title })
    }
    
    @Environment(NavigationState.self) private var navigationState
    @Environment(\.managedObjectContext) private var context
    
    @Dependency(\.messageClient) private var messageClient
    
    public init() {}
    
    public var body: some View {
        NavigationStack(path: .init(get: { navigationState.showListPath }, set: { navigationState.showListPath = $0 })) {
            Group {
                if shows.isEmpty {
                    ContentUnavailableView(
                        label: {
                            Label(
                                title: { Text("No shows", bundle: .module) },
                                icon: { Image(systemName: "music.quarternote.3") }
                            )
                        },
                        actions: {
                            Button(action: { navigationState.showSearchPath = [] }) {
                                Text("Follow your favorite shows!", bundle: .module)
                            }
                        }
                    )
                } else {
                    List {
                        ForEach(shows) { show in
                            NavigationLink(
                                value: ShowListRoute.showDetail(
                                    args: .init(
                                        showsEpisodeActionButtons: true,
                                        feedURL: show.feedURL,
                                        imageURL: show.imageURL,
                                        title: show.title,
                                        episodes: show.episodes,
                                        author: show.author,
                                        description: show.description,
                                        linkURL: show.linkURL,
                                        followed: true
                                    )
                                )
                            ) {
                                ShowRowView(feedURL: show.feedURL, imageURL: show.imageURL, title: show.title, author: show.author)
                            }
                            .swipeActions(allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    guard let showRecord = showRecords.first(where: { $0.feedURL == show.feedURL }) else {
                                        return
                                    }
                                    context.delete(showRecord)
                                    context.saveWithErrorHandling { _ in
                                        messageClient.presentError(String(localized: "Failed to unfollow the show", bundle: .module))
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .tint(.red)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        navigationState.showSearchPath = []
                    } label: {
                        Image(systemName: "plus")
                            .bold()
                    }
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .navigationTitle(Text("Shows", bundle: .module))
            .navigationDestination(for: ShowListRoute.self) { route in
                switch route {
                case .showDetail(let args):
                    ShowDetailScreen(args: args)
                }
            }
            .sheet(isPresented: .init(
                get: { navigationState.showSearchPath != nil },
                set: { _ in navigationState.showSearchPath = nil }
            )) {
                ShowSearchScreen()
            }
        }
    }
}
