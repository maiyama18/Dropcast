import ComposableArchitecture
import ShowDetailFeature
import SwiftUI

public struct ShowListScreen: View {
    @ObservedObject var viewModel: ShowListViewModel
    
    public var body: some View {
        Group {
            if let shows = viewModel.shows {
                if shows.isEmpty {
                    emptyView(
                        onButtonTapped: {
                            Task { await viewModel.handle(action: .tapSearchShowsButton) }
                        }
                    )
                } else {
                    List {
                        ForEach(shows) { show in
                            ShowRowView(show: SimpleShow(show: show))
                                .onTapGesture {
                                    Task {
                                        await viewModel.handle(action: .tapShowRow)
                                    }
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
                    Task { await viewModel.handle(action: .tapSearchShowsButton) }
                } label: {
                    Image(systemName: "plus")
                        .bold()
                }
            }
        }
        .navigationTitle(L10n.shows)
    }

    @ViewBuilder
    private func emptyView(onButtonTapped: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            Image(systemName: "face.dashed")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Spacer()
                .frame(height: 8)

            Text(L10n.noShows)
                .font(.title3.bold())
                .foregroundStyle(.secondary)

            Spacer()
                .frame(height: 16)

            Button(L10n.followFavoriteShows) {
                onButtonTapped()
            }
            .tint(.orange)
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }
}
