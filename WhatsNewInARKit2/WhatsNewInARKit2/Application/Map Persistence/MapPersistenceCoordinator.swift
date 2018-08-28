import UIKit

class MapPersistenceCoordinator: Coordinator {
    private var presenter: UINavigationController
    private var persistingViewController: PersistingMapViewController?
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
    }
    
    func start() {
        let persistingViewController = PersistingMapViewController(nibName: nil, bundle: nil)
        persistingViewController.title = "Persistence Demo"
        presenter.pushViewController(persistingViewController, animated: true)
        
        self.persistingViewController = persistingViewController
    }
}
