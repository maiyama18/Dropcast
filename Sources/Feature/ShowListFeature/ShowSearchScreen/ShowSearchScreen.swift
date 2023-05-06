import Dependencies
import SwiftUI

struct ShowSearchScreen: View {
    @ObservedObject var viewModel: ShowSearchViewModel

    @Dependency(\.continuousClock) private var clock

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField(
                    "Search",
                    text: .init(get: { viewModel.query }, set: { viewModel.handle(action: .changeQuery(query: $0)) }),
                    prompt: Text("Podcast Title, Feed URL, Author...")
                )
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .textFieldStyle(.plain)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal, 12)

            Group {
                switch viewModel.searchState {
                case .prompt:
                    labelView(title: L10n.searchShows)
                case .empty:
                    labelView(title: L10n.noResults)
                case .loaded(let shows):
                    List {
                        ForEach(shows) { show in
                            ShowRowView(show: SimpleShow(iTunesShow: show))
                                .tint(.primary)
                                .onTapGesture {
                                    viewModel.handle(action: .tapShowRow(show: show))
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .overlay {
            if viewModel.isSearching {
                ProgressView()
                    .scaleEffect(2)
            }
        }
        .navigationTitle(L10n.followShows)
        .task(id: viewModel.query) {
            do {
                try await clock.sleep(for: .milliseconds(300))
                viewModel.handle(action: .debounceQuery)
            } catch {}
        }
    }

    @ViewBuilder
    private func labelView(title: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle.bold())

            Text(title)
                .font(.title2)
        }
        .foregroundStyle(.secondary)
        .frame(maxHeight: .infinity, alignment: .center)
    }
}
