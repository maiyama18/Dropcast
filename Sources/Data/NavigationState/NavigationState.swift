import Observation

@Observable
public final class NavigationState {
    public static let shared = NavigationState()
    
    public var mainTab: MainTab = .feed
    
    // feed tab
    
    // library tab
    public var showListPath: [ShowListRoute] = []
    
    public var showSearchPath: [ShowSearchRoute]? = nil
    
    // settings tab
    public var settingsPath: [SettingsRoute] = []
}
