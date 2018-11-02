//
//  MoleculeViewController.swift
//  Swifty Protein
//
//  Created by Jimmy CHEN-MA on 10/31/18.
//  Copyright © 2018 Jimmy CHEN-MA. All rights reserved.
//

import UIKit
import SceneKit

class MoleculeViewController: UIViewController
{
    var molecule: MoleculeInfo?
    var sphereNodeDic: [Int: SCNNode] = [:]
    var camera = SCNCamera()
    var size: CGFloat = 0.3
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var navBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navBar.title = molecule?.name
        
        let cameraNode = SCNNode()
        cameraNode.camera = self.camera
        cameraNode.position = SCNVector3(x: -3.0, y: 3.0, z: 3.0)
        
        let scene = SCNScene()
        sceneView.scene = scene
        scene.rootNode.addChildNode(cameraNode)
        
        for atom in molecule!.atom {
            let sphere = SCNSphere(radius: self.size)
            sphere.segmentCount = 30
            
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.position = SCNVector3(x: atom.x, y: atom.y, z: atom.z)
            
            let constraint = SCNLookAtConstraint(target: sphereNode)
            constraint.isGimbalLockEnabled = true
            cameraNode.constraints = [constraint]
            
            scene.rootNode.addChildNode(sphereNode)
            sphereNodeDic[atom.id] = sphereNode
        }
        
        for conect in molecule!.conect {
            for (index, id) in conect.ids.enumerated() {
                if index == 0 {continue}
                
                guard let node1 = sphereNodeDic[conect.ids[0]]?.position else {continue}
                guard let node2 = sphereNodeDic[id]?.position else {continue}
                
                let line = SCNCylinder(radius: 0.05, height: node1.distance(to: node2))
                let newLine = SCNNode(geometry: line)
                newLine.position = SCNVector3Make((node1.x + node2.x) / 2, (node1.y + node2.y) / 2, (node1.z + node2.z) / 2)
                let dirVector = SCNVector3Make(node2.x - node1.x, node2.y - node1.y, node2.z - node1.z)
                
                // Get Y rotation in radians
                let yAngle = atan(dirVector.x / dirVector.z)
                
                // Rotate cylinder node about X axis so cylinder is laying down
                newLine.eulerAngles.x = .pi / 2
//                newLine.eulerAngles.z = asin(dirVector.x / dirVector.y)
                
                // Rotate cylinder node about Y axis so cylinder is pointing to each node
                newLine.eulerAngles.y = yAngle
                
                scene.rootNode.addChildNode(newLine)

            }
            // Create Cylinder Geometry
            
            
            // Create Cylinder(line) Node
            
            
            
            
            // This is the change in x,y and z between node1 and node2
         

            
            
            
//
//            let cylinder = SCNCylinder(radius: 0.04, height: 0.5)
//            let sphere = SCNSphere(radius: self.size)
//            sphere.segmentCount = 30
//
//            let sphereNode = SCNNode(geometry: sphere)
//            sphereNode.position = SCNVector3(x: atom.x, y: atom.y, z: atom.z)
//
//            let constraint = SCNLookAtConstraint(target: sphereNode)
//            constraint.isGimbalLockEnabled = true
//            cameraNode.constraints = [constraint]
//
//            scene.rootNode.addChildNode(sphereNode)
        }
        
        let light = SCNLight()
        light.type = SCNLight.LightType.omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 1.5, y: 1.5, z: 1.5)
        scene.rootNode.addChildNode(lightNode)
    
//        let constraint = SCNLookAtConstraint(target: sphereNode)
//        constraint.isGimbalLockEnabled = true
//        cameraNode.constraints = [constraint]
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SCNVector3 {
    func distance(to destination: SCNVector3) -> CGFloat {
        let dx = destination.x - x
        let dy = destination.y - y
        let dz = destination.z - z
        return CGFloat(sqrt(dx*dx + dy*dy + dz*dz))
    }
}
