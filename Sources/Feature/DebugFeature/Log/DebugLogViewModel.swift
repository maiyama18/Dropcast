import Combine
import Dependencies
import Logger
import MessageClient

enum SearchScope: Hashable {
    case all
    case category(LogCategory)
}

@MainActor
final class DebugLogViewModel: ObservableObject {
    @Published private(set) var loading: Bool = false
    @Published private(set) var allLogEntries: [LogEntry] = []
    @Published var query: String = ""
    @Published var searchScope: SearchScope = .all

    @Dependency(\.messageClient) private var messageClient

    private let logStore = LogStore()

    var visibleEntries: [LogEntry] {
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

    func task() async {
        guard allLogEntries.isEmpty else { return }

        loading = true
        defer { loading = false }

        do {
            allLogEntries = try await logStore.getAllLogEntries()
        } catch {
            messageClient.presentError("Failed to fetch logs: \(error)")
        }
    }
}
