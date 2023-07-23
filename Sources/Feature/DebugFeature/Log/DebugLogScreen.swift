import Dependencies
import Logger
import MessageClient
import SwiftUI

struct DebugLogScreen: View {
    enum SearchScope: Hashable {
        case all
        case category(LogCategory)
    }
    
    @State private var allLogEntries: [LogEntry] = []
    @State private var searchScope: SearchScope = .all
    @State private var query: String = ""
    @State private var loading: Bool = false
    
    @Dependency(\.messageClient) private var messageClient
    
    private let logStore = LogStore()
    
    private var visibleEntries: [LogEntry] {
        let scopedEntries: [LogEntry]
        switch searchScope {
        case .all:
            scopedEntries = allLogEntries
        case .category(let category):
            scopedEntries = allLogEntries.filter { $0.category == category }
        }

        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        if trimmedQuery.isEmpty {
            return scopedEntries
        }
        return scopedEntries.filter { $0.message.contains(trimmedQuery) }
    }
    
    var body: some View {
        Group {
            if loading {
                ProgressView()
                    .scaleEffect(2)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    Picker(selection: $searchScope) {
                        Text("all").tag(SearchScope.all)
                        ForEach(LogCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(SearchScope.category(category))
                        }
                    } label: {
                        Text("Category")
                    }

                    List {
                        ForEach(visibleEntries, id: \.date) { entry in
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
                .searchable(text: $query)
            }
        }
        .task {
            guard allLogEntries.isEmpty else { return }

            loading = true
            defer { loading = false }

            do {
                allLogEntries = try await logStore.getAllLogEntries()
            } catch {
                messageClient.presentError("Failed to fetch logs: \(error)")
            }
        }
        .navigationTitle("Log")
    }
}
