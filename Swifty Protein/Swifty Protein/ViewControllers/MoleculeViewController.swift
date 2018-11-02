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
    
    private func getAtomColor(element:String) -> UIColor
    {
        // using Rasmol CPK Color
        switch element {
        case "H", "D", "T":
            return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        case "He":
            return UIColor(red: 254/255, green: 193/255, blue: 203/255, alpha: 1)
        case "Li":
            return UIColor(red: 176/255, green: 36/255, blue: 40/255, alpha: 1)
        case "B", "Cl":
            return UIColor(red: 41/255, green: 253/255, blue: 47/255, alpha: 1)
        case "C":
            return UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        case "N":
            return UIColor(red: 144/255, green: 146/255, blue: 252/255, alpha: 1)
        case "O":
            return UIColor(red: 237/255, green: 12/255, blue: 25/255, alpha: 1)
        case "F", "Si", "Au":
            return UIColor(red: 217/255, green: 164/255, blue: 50/255, alpha: 1)
        case "Na":
            return UIColor(red: 11/255, green: 36/255, blue: 251/255, alpha: 1)
        case "Mg":
            return UIColor(red: 40/255, green: 138/255, blue: 42/255, alpha: 1)
        case "Al", "Ca", "Ti", "Cr", "Mn", "Ag":
            return UIColor(red: 128/255, green: 128/255, blue: 143/255, alpha: 1)
        case "P", "Fe", "Ba":
            return UIColor(red: 253/255, green: 164/255, blue: 40/255, alpha: 1)
        case "S":
            return UIColor(red: 254/255, green: 199/255, blue: 68/255, alpha: 1)
        case "Ni", "Cu", "Zn", "Br":
            return UIColor(red: 163/255, green: 43/255, blue: 46/255, alpha: 1)
        default:
            return UIColor(red: 252/255, green: 34/255, blue: 147/255, alpha: 1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navBar.title = molecule?.name

        let scene = SCNScene()
        
        for atom in molecule!.atom {
            let sphere = SCNSphere(radius: self.size)
            sphere.segmentCount = 30
            sphere.firstMaterial?.diffuse.contents = getAtomColor(element: atom.element)
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.position = SCNVector3(x: atom.x, y: atom.y, z: atom.z)
            
            scene.rootNode.addChildNode(sphereNode)
            sphereNodeDic[atom.id] = sphereNode
        }
        
        for conect in molecule!.conect {
            for (index, id) in conect.ids.enumerated() {
                if index == 0 {continue}

                guard let node1 = sphereNodeDic[conect.ids[0]]?.position else {continue}
                guard let node2 = sphereNodeDic[id]?.position else {continue}

                scene.rootNode.addChildNode(CylinderLine(parent: scene.rootNode, v1: node1, v2: node2, radius: 0.05, color: UIColor.white))
            }
        }
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.black
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SCNVector3 {
    func distance(receiver: SCNVector3) -> Float {
        let xd = receiver.x - self.x
        let yd = receiver.y - self.y
        let zd = receiver.z - self.z
        let distance = Float(sqrt(xd * xd + yd * yd + zd * zd))
        
        if (distance < 0){
            return (distance * -1)
        } else {
            return (distance)
        }
    }
}

class   CylinderLine: SCNNode
{
    init( parent: SCNNode,//Needed to add destination point of your line
        v1: SCNVector3,//source
        v2: SCNVector3,//destination
        radius: CGFloat,//somes option for the cylinder
        color: UIColor )// color of your node object
    {
        super.init()
        
        //Calcul the height of our line
        let  height = v1.distance(receiver: v2)
        //set position to v1 coordonate
        position = v1
        //Create the second node to draw direction vector
        let nodeV2 = SCNNode()
        //define his position
        nodeV2.position = v2
        //add it to parent
        parent.addChildNode(nodeV2)
        //Align Z axis
        let zAlign = SCNNode()
        zAlign.eulerAngles.x = .pi / 2
        //create our cylinder
        let cyl = SCNCylinder(radius: radius, height: CGFloat(height))
        cyl.firstMaterial?.diffuse.contents = color
        //Create node with cylinder
        let nodeCyl = SCNNode(geometry: cyl )
        nodeCyl.position.y = -height/2
        zAlign.addChildNode(nodeCyl)
        //Add it to child
        addChildNode(zAlign)
        //set contrainte direction to our vector
        constraints = [SCNLookAtConstraint(target: nodeV2)]
    }
    
    override init() {
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
