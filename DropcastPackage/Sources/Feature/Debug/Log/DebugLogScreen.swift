import Logger
import SwiftUI

struct DebugLogScreen: View {
    @StateObject private var viewModel: DebugLogViewModel = .init()

    var onMessageTapped: (String) -> Void

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
                            DebugLogRowView(entry: entry)
                                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .containerShape(Rectangle())
                                .onTapGesture {
                                    onMessageTapped(entry.message)
                                }
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
        .onChange(of: viewModel.searchScope) {
            print($0)
        }
    }
}
