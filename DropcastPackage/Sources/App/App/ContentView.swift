import AppFeature
import DebugFeature
import Dependencies
import Logger
import MessageClientLive
import SwiftUI

public struct ContentView: View {
    @Dependency(\.logger[.app]) var logger
    
    public init() {
        logger.notice("app launched")
    }

    public var body: some View {
        AppScreen()
            .debugMenu()
            .tint(.orange)
    }
}
