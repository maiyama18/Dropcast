import SwiftUI

struct DebugMenuScreen: View {
    enum Route: Hashable {
        case log
        case coreData
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
                Button("Inspect Core Data Objects") {
                    path.append(.coreData)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Debug Menu")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .coreData:
                    Text("CoreData")
                case .log:
                    Text("Log")
                }
            }
        }
    }
}
