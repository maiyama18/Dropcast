import Dependencies
import UIKit
import ViewFactory

internal enum Tab: Int {
    case feed
    case shows
    case settings
}

public final class MainTabBarController: UITabBarController {
    @Dependency(\.viewFactory) private var viewFactory
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        setupTabs()
    }

    private func setupTabs() {
        let feedViewController = UINavigationController(rootViewController: viewFactory.makeFeed())
        feedViewController.tabBarItem = UITabBarItem(title: L10n.feed, image: UIImage(systemName: "dot.radiowaves.up.forward"), tag: Tab.feed.rawValue)

        let showsViewController = DummyViewController(text: "shows")
        showsViewController.tabBarItem = UITabBarItem(title: L10n.shows, image: UIImage(systemName: "square.stack.3d.down.right"), tag: Tab.shows.rawValue)
        
        let settingsViewController = UINavigationController(rootViewController: viewFactory.makeSettings())
        settingsViewController.tabBarItem = UITabBarItem(title: L10n.settings, image: UIImage(systemName: "gearshape"), tag: Tab.settings.rawValue)
        
        viewControllers = [feedViewController, showsViewController, settingsViewController]
    }
}

final class DummyViewController: UIViewController {
    private let text: String
    
    init(text: String) {
        self.text = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = text
        
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}
