import ClipboardClient
import Dependencies
import MessageClient
import SwiftUI

struct DebugLogDetailScreen: View {
    var message: String
    
    @Dependency(\.clipboardClient) private var clipboardClient
    @Dependency(\.messageClient) private var messageClient
    
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
                            messageClient.presentSuccess("Copied!")
                        }
                    }
                }
        }
    }
}
