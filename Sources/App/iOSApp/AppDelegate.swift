import AVFoundation
import Dependencies
import Logger
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    @Dependency(\.logger[.app]) private var logger
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            logger.notice("complete setup of background audio")
        } catch {
            logger.error("Failed to setup background audio: \(error, privacy: .public)")
        }
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String) async {
        logger.notice("handleEventsForBackgroundURLSession")
    }
}
