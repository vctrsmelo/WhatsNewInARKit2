import UIKit

class ImageTrackingCoordinator: Coordinator {
    private var presenter: UINavigationController
    private var imageTrackingViewController: ImageTrackingViewController?
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
    }
    
    func start() {
        let vc = ImageTrackingViewController(nibName: nil, bundle: nil)
        vc.title = "Image Tracking Demo"
        presenter.pushViewController(vc, animated: true)
    
        self.imageTrackingViewController = vc
    }
}
