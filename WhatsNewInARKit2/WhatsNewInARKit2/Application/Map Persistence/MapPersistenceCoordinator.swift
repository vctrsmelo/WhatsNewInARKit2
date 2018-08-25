import UIKit

class MapPersistenceCoordinator: Coordinator {
    private var presenter: UINavigationController
    private var mapPersistenceViewController: MapPersistenceViewController?
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
    }
    
    func start() {
        let mapPersistenceViewController = MapPersistenceViewController(nibName: nil, bundle: nil)
        mapPersistenceViewController.title = "Persistence Demo"
        presenter.pushViewController(mapPersistenceViewController, animated: true)
        
        self.mapPersistenceViewController = mapPersistenceViewController
    }
}
