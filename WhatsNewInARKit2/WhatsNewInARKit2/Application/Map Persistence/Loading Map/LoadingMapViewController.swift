//
//  ViewController.swift
//  WhatsNewInARKit2
//
//  Created by Victor S Melo on 24/08/18.
//  Copyright © 2018 Victor Melo. All rights reserved.
//

import UIKit
import ARKit

class LoadingMapViewController: UIViewController, ARSCNViewDelegate  {
    
    
    @IBOutlet weak var sceneView: ARSCNView!
    //    let mugNode = SCNScene(named: "art.scnassets/mug.scn")!.rootNode
//    var plane: VirtualPlane!
    
    @IBOutlet weak var stateLabel: UILabel!
    
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
        
        do {
            let worldMap = try loadWorldMap(from: fileURL)
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            configuration.initialWorldMap = worldMap
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        } catch {
            print(error.localizedDescription)
        }

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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if let name = anchor.name, name.hasPrefix("mugAnchor") {
            node.addChildNode(loadMug())
            return
        }
    }
    
    // MARK: - AR session management
    private func loadMug() -> SCNNode {
        let sceneURL = Bundle.main.url(forResource: "mug", withExtension: "scn", subdirectory: "art.scnassets")!
        let referenceNode = SCNReferenceNode(url: sceneURL)!
        referenceNode.load()
        return referenceNode
    }
    
    func cleanupARSession() {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
            node.removeFromParentNode()
        }
    }
    
    func loadWorldMap(from url: URL) throws -> ARWorldMap {
        let mapData = try Data(contentsOf: url)
        guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [ARWorldMap.classForKeyedUnarchiver()], from: mapData) as? ARWorldMap
            else { throw ARError(.invalidWorldMap) }
        print("loaded")
        return worldMap
    }
}
