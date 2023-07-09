import Dependencies
import ScreenTransitionCoordinator
import ShowDetailFeature
import SwiftUI

public struct ShowListScreen: View {
    @StateObject private var viewModel: ShowListViewModel = .init()

    @Dependency(\.screenTransitionCoordinator) private var coordinator

    public init() {}

    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            Group {
                if let shows = viewModel.shows {
                    if shows.isEmpty {
                        ContentUnavailableView(
                            label: {
                                Label(
                                    title: { Text("No shows", bundle: .module) },
                                    icon: { Image(systemName: "music.quarternote.3") }
                                )
                            },
                            actions: {
                                Button(action: { Task { await viewModel.handle(action: .tapAddButton) } }) {
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
                                    ShowRowView(show: SimpleShow(show: show))
                                }
                                .swipeActions(allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        Task {
                                            await viewModel.handle(action: .swipeToDeleteShow(feedURL: show.feedURL))
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
                } else {
                    ProgressView()
                        .scaleEffect(2)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await viewModel.handle(action: .tapAddButton) }
                    } label: {
                        Image(systemName: "plus")
                            .bold()
                    }
                }
            }
            .navigationTitle(Text("Shows", bundle: .module))
            .navigationDestination(for: ShowListRoute.self) { route in
                switch route {
                case .showDetail(let args):
                    ShowDetailScreen(args: args)
                }
            }
            .sheet(isPresented: $viewModel.showSearchPresented) {
                ShowSearchScreen()
            }
            .task {
                for await _ in coordinator.openShowSearch {
                    await viewModel.handle(action: .tapAddButton)
                }
            }
        }
    }
}
