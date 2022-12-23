//
//  ViewController.swift
//  AR-Scientist
//
//  Created by Jake Choi on 12/22/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    // scientists dictionary which has strings of keys and scientists both value
    var scienists = [String: Scientist]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        // trying to find a images
        let configuration = ARImageTrackingConfiguration()
        
        // find a images from in asset "scientist"
        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "scientist", bundle: nil) else {
            fatalError("Couldn't load tracking images")
        }
        
        configuration.trackingImages = trackingImages


        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // nodefor
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        // trying to convert ARAnchor which could be some replaced or something detected to an image anchor from images
        guard let imageAnchor = anchor as? ARImageAnchor else { return nil }
       
        // make scene kit plane that has two dimensional width and height
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        // set color blue for now
        plane.firstMaterial?.diffuse.contents = UIColor.blue
        
        // warp in to a node set geometry position to plane so when camera moves also the node follows movement
        let planeNode = SCNNode(geometry: plane)
        
        // make it flat to down 90'
        planeNode.eulerAngles.x = -.pi / 2
        
        // make new empty SCNNode add planenode to that and return node
        let node = SCNNode()
        node.addChildNode(planeNode)
        
        return node
    }
    
    func loadData() {
        guard let url = Bundle.main.url(forResource: "scientists", withExtension: "json") else {
            fatalError("Unable to find JSON in bundle")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Unale to load JSON")
        }
        
            let decoder = JSONDecoder()
            
        guard let loadedScientists = try? decoder.decode([String: Scientist].self, from: data) else {
            fatalError("Unable to parse JSON")
        }
        scienists = loadedScientists
    }
}
