import Combine
import Dependencies
import Logger
import MessageClient

@MainActor
final class DebugLogViewModel: ObservableObject {
    @Published private(set) var loading: Bool = false
    @Published private(set) var allLogEntries: [LogEntry] = []
    @Published var query: String = ""
    
    @Dependency(\.messageClient) private var messageClient
    
    private let logStore = LogStore()
    
    var visibleEntries: [LogEntry] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        if trimmedQuery.isEmpty {
            return allLogEntries
        }
        return allLogEntries.filter { $0.message.contains(trimmedQuery) }
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
