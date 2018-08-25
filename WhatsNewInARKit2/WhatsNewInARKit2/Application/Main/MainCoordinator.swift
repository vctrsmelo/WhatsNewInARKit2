import UIKit

class MainCoordinator: Coordinator {

    private let presenter: UINavigationController
    private var mainViewController: MainViewController?
    
    private let flowsTitle = ["Map Persistence"]

    
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
            break
        default:
            break
        }
    }
}
