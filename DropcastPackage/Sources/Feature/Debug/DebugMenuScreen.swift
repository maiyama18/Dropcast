import SwiftUI

struct DebugMenuScreen: View {
    enum Route: Hashable {
        case log
        case logDetail(message: String)
    }
    
    @State private var path: [Route] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                Button("Copy SoundFiles Path") {
                    print("copy")
                }
                Button("Show Log") {
                    path.append(.log)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Debug Menu")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .log:
                    DebugLogScreen(onMessageTapped: { path.append(.logDetail(message: $0)) })
                case .logDetail(let message):
                    DebugLogDetailScreen(message: message)
                }
            }
        }
    }
}
