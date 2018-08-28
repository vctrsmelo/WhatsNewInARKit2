import UIKit

class EnvironmentTextureCoordinator: Coordinator {
    private var presenter: UINavigationController
    private var environmentTextureViewController: EnvironmentTextureViewController?
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
    }
    
    func start() {
        let vc = EnvironmentTextureViewController()
        vc.title = "Texture Demo"
        presenter.pushViewController(vc, animated: true)
        self.environmentTextureViewController = vc
    }
}
