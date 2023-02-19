import Combine
import Dependencies
import Logger
import MessageClient

@MainActor
final class DebugLogViewModel: ObservableObject {
    @Published private(set) var loading: Bool = false
    @Published private(set) var query: String = ""
    @Published private(set) var allLogEntries: [LogEntry] = []
    
    @Dependency(\.messageClient) private var messageClient
    
    private let logStore = LogStore()
    
    func task() async {
        loading = true
        defer { loading = false }
        
        do {
            allLogEntries = try await logStore.getAllLogEntries()
        } catch {
            messageClient.presentError("Failed to fetch logs: \(error)")
        }
    }
}
