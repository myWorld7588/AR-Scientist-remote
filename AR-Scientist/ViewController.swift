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
    var scientists = [String: Scientist]()

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
        // and name and scientist ANCHOR
        guard let name = imageAnchor.referenceImage.name else { return nil }
        guard let scientist = scientists[name] else { return nil }
        
        // make scene kit plane that has two dimensional width and height
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        
        // CHANGE blue to clear
        plane.firstMaterial?.diffuse.contents = UIColor.clear

        
        // warp in to a node set geometry position to plane so when camera moves also the node follows movement
        let planeNode = SCNNode(geometry: plane)
        
        // make it flat to down 90'
        planeNode.eulerAngles.x = -.pi / 2
        
        // make new empty SCNNode add planenode to that and return node
        let node = SCNNode()
        node.addChildNode(planeNode)
        
        // give spacing between titles and bio on the screen
        let spacing: Float = 0.005

        // Make First Node - Show name
        let titleNode = textNode(scientist.name, font: UIFont.boldSystemFont(ofSize: 10))
        titleNode.pivotOnTopLeft()

        titleNode.position.x += Float(plane.width / 2) + spacing
        titleNode.position.y += Float(plane.height / 2)

        planeNode.addChildNode(titleNode)
        
        // show bio
        let bioNode = textNode(scientist.bio, font: UIFont.systemFont(ofSize: 4), maxWidth: 100)
        bioNode.pivotOnTopLeft()
        
        bioNode.position.x += Float(plane.width / 2) + spacing
        bioNode.position.y = titleNode.position.y - titleNode.height - spacing
        planeNode.addChildNode(bioNode)
    
        return node
    }

    // load json
    func loadData() {
        guard let url = Bundle.main.url(forResource: "scientists", withExtension: "json") else {
            fatalError("Unable to find JSON in bundle")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Unable to load JSON")
        }

        let decoder = JSONDecoder()

        guard let loadedScientists = try? decoder.decode([String: Scientist].self, from: data) else {
            fatalError("Unable to parse JSON.")
        }

        scientists = loadedScientists
    }

    // Text size
    func textNode(_ str: String, font: UIFont, maxWidth: Int? = nil) -> SCNNode {
        let text = SCNText(string: str, extrusionDepth: 0)

        // give text flatness 0.1
        text.flatness = 0.1
        text.font = font
        
        // Draw ContainerFrame that wraps text insdie
        if let maxWidth = maxWidth {
            text.containerFrame = CGRect(origin: .zero, size: CGSize(width: maxWidth, height: 500))
            text.isWrapped = true
        }
        // Make textNode Scale Tiny
        let textNode = SCNNode(geometry: text)
        textNode.scale = SCNVector3(0.002, 0.002, 0.002)

        return textNode
    }
}

//The minimum and maximum corner points of the object’s bounding box.
extension SCNNode {
    var height: Float {
        return (boundingBox.max.y - boundingBox.min.y) * scale.y
    }

    func pivotOnTopLeft() {
        let (min, max) = boundingBox
        pivot = SCNMatrix4MakeTranslation(min.x, max.y, 0)
    }

    func pivotOnTopCenter() {
        let (_, max) = boundingBox
        pivot = SCNMatrix4MakeTranslation(0, max.y, 0)
    }
}
