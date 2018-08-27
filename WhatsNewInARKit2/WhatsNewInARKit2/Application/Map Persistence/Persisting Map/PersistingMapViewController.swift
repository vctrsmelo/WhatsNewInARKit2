//
//  ViewController.swift
//  WhatsNewInARKit2
//
//  Created by Victor S Melo on 24/08/18.
//  Copyright © 2018 Victor Melo. All rights reserved.
//

import UIKit
import ARKit

class PersistingMapViewController: UIViewController, ARSCNViewDelegate  {

    @IBOutlet weak var sceneView: ARSCNView!
    let mugNode = SCNScene(named: "art.scnassets/mug.scn")!.rootNode
    var plane: VirtualPlane!
    @IBOutlet weak var stateLabel: UILabel!
    let mugAnchorName = "mugAnchor"
    
    private let fileURL: URL = {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true)[0] as String
        return URL(fileURLWithPath: "\(documentsDirectory)/worldMap")
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self

        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

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
        sceneView.session.run(configuration)
        
        
        // Create a session configuration
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = .horizontal
//        do {
//            configuration.initialWorldMap = try loadWorldMap(from: fileURL)
//        } catch {
//            print(error.localizedDescription)
//        }
        
        // Run the view's session
//        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        
        switch camera.trackingState {
            
        case .notAvailable:
            stateLabel.text = "Not Available"
        case .limited(let reason):
            stateLabel.text = "Limited (reason: \(reason))"
        case .normal:
            stateLabel.text = "Normal"
        }
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if let name = anchor.name, name.hasPrefix("mugAnchor") {
            node.addChildNode(loadMug())
            return
        }
    }
    
    func cleanupARSession() {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
            node.removeFromParentNode()
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
    
    // MARK: - AR session management
    private func loadMug() -> SCNNode {
        let sceneURL = Bundle.main.url(forResource: "mug", withExtension: "scn", subdirectory: "art.scnassets")!
        let referenceNode = SCNReferenceNode(url: sceneURL)!
        referenceNode.load()
        return referenceNode
    }
    
    
    @IBAction func didTouchClearButton(_ sender: UIButton) {
        cleanupARSession()
    }
    
    @IBAction func didTouchSaveButton(_ sender: UIButton) {
        sceneView.session.getCurrentWorldMap { (worldMap, error) in
            guard let worldMap = worldMap else {
                print(error!.localizedDescription)
                return
            }
            
            do {
                try self.saveWorldMap(worldMap, to: self.fileURL)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
//    @IBAction func didTouchLoadButton(_ sender: UIButton) {
//        do {
//            let worldMap = try self.loadWorldMap(from: fileURL)
//            let configuration = ARWorldTrackingConfiguration()
//            configuration.initialWorldMap = worldMap
//            sceneView.session.run(configuration)
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
    
    
    
    func saveWorldMap(_ worldMap: ARWorldMap, to url: URL) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
        try data.write(to: url)
        print("saved")
    }
    
    func loadWorldMap(from url: URL) throws -> ARWorldMap {
        let mapData = try Data(contentsOf: url)
        guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [ARWorldMap.classForKeyedUnarchiver()], from: mapData) as? ARWorldMap
            else { throw ARError(.invalidWorldMap) }
        print("loaded")
        return worldMap
    }
}

class VirtualPlane: SCNNode {
    var anchor: ARPlaneAnchor!
    var planeGeometry: SCNPlane!
    
    init(anchor: ARPlaneAnchor) {
        super.init()
        
        // (1) initialize anchor and geometry, set color for plane
        self.anchor = anchor
        self.planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let material = initializePlaneMaterial()
        self.planeGeometry!.materials = [material]
        
        // (2) create the SceneKit plane node. As planes in SceneKit are vertical, we need to initialize the y coordinate to 0,
        // use the z coordinate, and rotate it 90º.
        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1.0, 0.0, 0.0)
        
        // (3) update the material representation for this plane
        updatePlaneMaterialDimensions()
        
        // (4) add this node to our hierarchy.
        self.addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initializePlaneMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white.withAlphaComponent(0.50)
        return material
    }
    
    func updatePlaneMaterialDimensions() {
        // get material or recreate
        let material = self.planeGeometry.materials.first!
        
        // scale material to width and height of the updated plane
        let width = Float(self.planeGeometry.width)
        let height = Float(self.planeGeometry.height)
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(width, height, 1.0)
    }
}
