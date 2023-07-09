import Dependencies
import Logger
import MessageClient
import Observation

enum SearchScope: Hashable {
    case all
    case category(LogCategory)
}

@MainActor
@Observable
final class DebugLogViewModel {
    private(set) var loading: Bool = false
    private(set) var allLogEntries: [LogEntry] = []
    var query: String = ""
    var searchScope: SearchScope = .all

    @ObservationIgnored
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
