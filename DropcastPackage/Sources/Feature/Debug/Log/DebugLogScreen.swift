import Logger
import SwiftUI

struct DebugLogScreen: View {
    @StateObject private var viewModel: DebugLogViewModel = .init()
    
    var body: some View {
        Group {
            if viewModel.loading {
                ProgressView()
                    .scaleEffect(2)
            } else {
                List {
                        ForEach(viewModel.allLogEntries, id: \.date) { entry in
                            DebugLogRowView(entry: entry)
                                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        }
                }
                .listStyle(.plain)
            }
        }
        .task {
            await viewModel.task()
        }
        .navigationTitle("Log")
    }
}
