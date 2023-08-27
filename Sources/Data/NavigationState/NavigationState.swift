import Observation
import SwiftUI

@Observable
public final class NavigationState {
    public static let shared = NavigationState()
    
    public var mainTab: MainTab = .feed
    
    public var playerSheetModeOn: Bool = false
    
    // feed tab
    public var feedPath: [PodcastRoute] = []
    
    // library tab
    public var showListPath: [PodcastRoute] = []
    
    public var showSearchPath: [PodcastRoute]? = nil
    
    // settings tab
    public var settingsPath: [SettingsRoute] = []
    
    public func moveToShowDetail(args: ShowDetailInitArguments) async {
        playerSheetModeOn = false
        showListPath = []
        showSearchPath = nil
        mainTab = .library
        try? await Task.sleep(for: .milliseconds(300))
        
        showListPath.append(.showDetail(args: args))
    }
}
