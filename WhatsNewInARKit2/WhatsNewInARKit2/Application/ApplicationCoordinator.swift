import UIKit

class ApplicationCoordinator: Coordinator {
    let window: UIWindow
    let rootViewController: UINavigationController
    
    let mainCoordinator: MainCoordinator

    init(window: UIWindow) {
        self.window = window
        rootViewController = UINavigationController()
        rootViewController.navigationBar.prefersLargeTitles = true
        
        mainCoordinator = MainCoordinator(presenter: rootViewController)
    }
    
    func start() {
        window.rootViewController = rootViewController
        mainCoordinator.start()
        window.makeKeyAndVisible()
    }
}
