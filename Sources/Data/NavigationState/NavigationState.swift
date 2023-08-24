import Observation

@Observable
public final class NavigationState {
    public static let shared = NavigationState()
    
    public var mainTab: MainTab = .feed
    
    // feed tab
    
    // library tab
    public var showListPath: [PodcastRoute] = []
    
    public var showSearchPath: [PodcastRoute]? = nil
    
    // settings tab
    public var settingsPath: [SettingsRoute] = []
}
