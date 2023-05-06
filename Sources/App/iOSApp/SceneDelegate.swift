import DebugFeature
import MainTabFeature
import ShowListFeature
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = MainTabBarController()
        self.window = window
        #if DEBUG
        installDebugMenu(windowScene: windowScene)
        #endif
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url, let host = url.host() else {
            return
        }

        switch host {
        case "show-search":
            guard let mainTabVC = window?.rootViewController as? MainTabBarController,
                  let navigationVC = mainTabVC.changeTab(to: .shows) as? UINavigationController else {
                return
            }
            navigationVC.popToRootViewController(animated: false)
            guard let showListVC = navigationVC.viewControllers.first as? ShowListViewController else {
                return
            }
            showListVC.dismiss(animated: false)
            
            showListVC.presentShowSearch()
        default:
            break
        }
    }
}
