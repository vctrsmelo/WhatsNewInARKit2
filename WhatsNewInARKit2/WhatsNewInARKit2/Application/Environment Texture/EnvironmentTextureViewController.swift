import ARKit
import UIKit

class EnvironmentTextureViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene()
        self.sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Enable automatic environment texturing
        configuration.environmentTexturing = .automatic

        sceneView.session.run(configuration)
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let name = anchor.name, name.hasPrefix("mugAnchor") {
            let mug = loadMug()
        
            node.addChildNode(mug)
            return
        }
    }
    
    @IBAction func handleSceneTap(_ sender: UITapGestureRecognizer) {
        
        guard let hitTestResult = sceneView
            .hitTest(sender.location(in: sceneView), types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane])
            .first
            else { return }
        
        // Place an anchor for a virtual character. The model appears in renderer(_:didAdd:for:).
        let anchor = ARAnchor(name: "mugAnchor", transform: hitTestResult.worldTransform)
        sceneView.session.add(anchor: anchor)
    }
    
    @IBAction func didTouchClearButton(_ sender: UIButton) {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
            node.removeFromParentNode()
        }
    }
    
    private func loadMug() -> SCNNode {
        let sceneURL = Bundle.main.url(forResource: "mug", withExtension: "scn", subdirectory: "art.scnassets")!
        let referenceNode = SCNReferenceNode(url: sceneURL)!
        
        referenceNode.load()
        return referenceNode
    }
}
