import UIKit

class MapPersistenceCoordinator: Coordinator {
    private var presenter: UINavigationController
    private var persistingViewController: PersistingMapViewController?
    private var loadingMapViewController: LoadingMapViewController?
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
    }
    
    func start() {
        let persistingViewController = PersistingMapViewController(nibName: nil, bundle: nil)
        persistingViewController.title = "Persistence Demo"
        persistingViewController.navigationItem.setRightBarButton(UIBarButtonItem(title: "Load Demo", style: .plain, target: self, action: #selector(presentLoadingMapViewController))
            , animated: false)
        
        presenter.pushViewController(persistingViewController, animated: true)
        
        self.persistingViewController = persistingViewController
    }
    
    @objc
    func presentLoadingMapViewController(sender: UIBarButtonItem) {
        let loadingMapViewController = LoadingMapViewController(nibName: nil, bundle: nil)
        loadingMapViewController.title = "Loading Demo"
        presenter.pushViewController(loadingMapViewController, animated: true)
        self.loadingMapViewController = loadingMapViewController
    }
}
