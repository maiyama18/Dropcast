#if DEBUG
import ClipboardClient
import DebugMenu
import Dependencies
import MessageClient
import SoundFileState

struct CopySoundFilesRootPathItem: DebugItem {
    @Dependency(\.clipboardClient) private var clipboardClient
    @Dependency(\.messageClient) private var messageClient

    let debugItemTitle: String = "Copy Sound Files Path"

    var action: DebugItemAction {
        .execute {
            await clipboardClient.copy(SoundFileState.soundFilesRootDirectoryURL.absoluteString)
            messageClient.presentSuccess("Copied!")
            return .success()
        }
    }
}
#endif
