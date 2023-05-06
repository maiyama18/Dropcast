import Logger
import SwiftUI

struct DebugLogScreen: View {
    @ObservedObject private var viewModel: DebugLogViewModel
    
    init(viewModel: DebugLogViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Group {
            if viewModel.loading {
                ProgressView()
                    .scaleEffect(2)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    Picker(selection: $viewModel.searchScope) {
                        Text("all").tag(SearchScope.all)
                        ForEach(LogCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(SearchScope.category(category))
                        }
                    } label: {
                        Text("Category")
                    }
                    
                    List {
                        ForEach(viewModel.visibleEntries, id: \.date) { entry in
                            NavigationLink {
                                DebugLogDetailScreen(message: entry.message)
                            } label: {
                                DebugLogRowView(entry: entry)
                            }
                            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        }
                    }
                    .listStyle(.plain)
                }
                .searchable(text: $viewModel.query)
            }
        }
        .task {
            await viewModel.task()
        }
        .navigationTitle("Log")
    }
}
