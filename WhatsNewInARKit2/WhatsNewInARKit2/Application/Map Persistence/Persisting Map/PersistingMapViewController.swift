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
    @IBOutlet weak var stateLabel: UILabel!
    
    private var mugAnchors: [ARAnchor] = []
    
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
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        
        switch camera.trackingState {
            
        case .notAvailable:
            stateLabel.text = "Not Available"
        case .limited(let reason):
            stateLabel.text = "Limited (reason: \(reason)) - Save a scene?"
        case .normal:
            stateLabel.text = "Normal"
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if let name = anchor.name, name.hasPrefix("mugAnchor") {
            mugAnchors.append(anchor)
            node.addChildNode(loadMug())
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
        while !mugAnchors.isEmpty {
            sceneView.session.remove(anchor: mugAnchors.popLast()!)
        }
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
            node.removeFromParentNode()
        }
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
    
    func saveWorldMap(_ worldMap: ARWorldMap, to url: URL) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
        try data.write(to: url)
        print("saved")
    }
    
    private func loadMug() -> SCNNode {
        let sceneURL = Bundle.main.url(forResource: "mug", withExtension: "scn", subdirectory: "art.scnassets")!
        let referenceNode = SCNReferenceNode(url: sceneURL)!
        referenceNode.load()
        return referenceNode
    }
    
    func loadWorldMap(from url: URL) throws -> ARWorldMap {
        let mapData = try Data(contentsOf: url)
        guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [ARWorldMap.classForKeyedUnarchiver()], from: mapData) as? ARWorldMap
            else { throw ARError(.invalidWorldMap) }
        print("loaded")
        return worldMap
    }
}
