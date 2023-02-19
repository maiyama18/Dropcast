import ClipboardClient
import Dependencies
import SwiftUI

struct DebugLogDetailScreen: View {
    var message: String
    
    @Dependency(\.clipboardClient) private var clipboardClient
    
    var body: some View {
        ScrollView {
            Text(message)
                .font(.caption.monospaced())
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Copy") {
                            clipboardClient.copy(message)
                        }
                    }
                }
        }
    }
}
