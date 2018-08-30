import UIKit

class MainCoordinator: Coordinator {

    private var mapPersistenceCoordinator: MapPersistenceCoordinator?
    private var environmentTextureCoordinator: EnvironmentTextureCoordinator?
    private var imageTrackingCoordinator: ImageTrackingCoordinator?
    
    private let presenter: UINavigationController
    private var mainViewController: MainViewController?
    
    private let flowsTitle = ["Map Persistence",
                              "Environment Texture",
                              "Image Tracking"]

    
    init(presenter: UINavigationController) {
        self.presenter = presenter
    }
    
    func start() {
        let mainViewController = MainViewController.init(nibName: nil, bundle: nil)
        mainViewController.delegate = self
        mainViewController.title = "What's new in ARKit 2"
        mainViewController.cellsTitle = flowsTitle
        presenter.pushViewController(mainViewController, animated: true)
        
        self.mainViewController = mainViewController
    }
}

extension MainCoordinator: MainViewControllerDelegate {
    func mainViewControllerDidSelectFlow(_ selectedFlow: String) {
        switch selectedFlow {
        case "Map Persistence":
            let mapPersistenceCoordinator = MapPersistenceCoordinator(presenter: presenter)
            mapPersistenceCoordinator.start()
            self.mapPersistenceCoordinator = mapPersistenceCoordinator
        case "Environment Texture":
            let environmentTextureCoordinator = EnvironmentTextureCoordinator(presenter: presenter)
            environmentTextureCoordinator.start()
            self.environmentTextureCoordinator = environmentTextureCoordinator
        case "Image Tracking":
            let imageTrackingCoordinator = ImageTrackingCoordinator(presenter: presenter)
            imageTrackingCoordinator.start()
            self.imageTrackingCoordinator = imageTrackingCoordinator
        default:
            break
        }
    }
}
