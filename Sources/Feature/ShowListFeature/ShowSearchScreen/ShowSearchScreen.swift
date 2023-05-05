import Dependencies
import SwiftUI

struct ShowSearchScreen: View {
    @ObservedObject var viewModel: ShowSearchViewModel
    
    @Dependency(\.continuousClock) private var clock
    
    var body: some View {
        Group {
            switch viewModel.searchState {
            case .prompt:
                labelView(title: L10n.searchShows)
            case .empty:
                labelView(title: L10n.noResults)
            case .loaded(let shows):
                List {
                    ForEach(shows) { show in
                        ShowRowView(show: show)
                            .tint(.primary)
                    }
                }
                .listStyle(.plain)
            }
        }
        .overlay {
            if viewModel.isSearching {
                ProgressView()
                    .scaleEffect(2)
            }
        }
        .navigationTitle(L10n.followShows)
        .searchable(
            text: .init(get: { viewModel.query }, set: { viewModel.handle(action: .changeQuery(query: $0)) }),
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text(L10n.searchPlaceholder)
        )
        .autocorrectionDisabled(true)
        .textInputAutocapitalization(.never)
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
