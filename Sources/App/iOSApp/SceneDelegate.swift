//    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//        guard let url = URLContexts.first?.url, let host = url.host() else {
//            return
//        }
//
//        switch host {
//        case "show-search":
//            guard let mainTabVC = window?.rootViewController as? MainTabBarController,
//                  let navigationVC = mainTabVC.changeTab(to: .shows) as? UINavigationController else {
//                return
//            }
//            navigationVC.popToRootViewController(animated: false)
//            guard let showListVC = navigationVC.viewControllers.first as? ShowListViewController else {
//                return
//            }
//            showListVC.dismiss(animated: false)
//
//            showListVC.presentShowSearch()
//        default:
//            break
//        }
