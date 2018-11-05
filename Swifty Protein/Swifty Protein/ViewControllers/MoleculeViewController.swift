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
    var hydrogeneCylinderNodeList: [SCNNode] = []
    var camera = SCNCamera()
    var size: CGFloat = 0.3
    var changeModel:Bool = false
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var atomElementText: UITextField!
    
    /*--------------------------------------*/
    /*---------------FUNCTION---------------*/
    /*--------------------------------------*/
    
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
    
    @objc func handleTap(rec: UITapGestureRecognizer)
    {
        if rec.state == .ended
        {
            let location: CGPoint = rec.location(in: sceneView)
            let hits = self.sceneView.hitTest(location, options: nil)
            if !hits.isEmpty
            {
                let tappedNode = hits.first?.node
                for atom in molecule!.atom
                {
                    if atom.x == tappedNode?.position.x && atom.y == tappedNode?.position.y && atom.z == tappedNode?.position.z
                    {
                        if atomElementText.isHidden
                        {
                            atomElementText.isHidden = false
                        }
                        atomElementText.text = String(describing: "Atom Element: " + "\(atom.element)")
                    }
                }
            }
            else
            {
                atomElementText.text = String(describing: "")
                atomElementText.isHidden = true
            }
        }
    }
    
    /*--------------------------------------*/
    /*----------------ACTION----------------*/
    /*--------------------------------------*/

    @IBAction func shareButton(_ sender: UIBarButtonItem)
    {
        // image to share
        let image = sceneView.snapshot()
        
        // set up activity view controller
        let imageToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [UIActivityType.airDrop]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func changeModelButton(_ sender: UIButton)
    {
        changeModel = !changeModel
        if changeModel == true  // without Hidrogene
        {
            for atomNode in sphereNodeDic
            {
                for atom in molecule!.atom
                {
                    if atom.x == atomNode.value.position.x && atom.y == atomNode.value.position.y && atom.z == atomNode.value.position.z && atom.element == "H"
                    {
                        atomNode.value.isHidden = true
                        break
                    }
                }
                for cylinderNode in hydrogeneCylinderNodeList {
                    cylinderNode.isHidden = true
                }
            }
        }
        else
        {
            for atomNode in sphereNodeDic
            {
                atomNode.value.isHidden = false
            }
            for cylinderNode in hydrogeneCylinderNodeList {
                cylinderNode.isHidden = false
            }
        }
    }
    
    /*--------------------------------------*/
    /*---------------OVERRIDE---------------*/
    /*--------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navBar.title = molecule?.name

        let scene = SCNScene()
        
//        let cameraNode = SCNNode()
//        cameraNode.camera = self.camera
//        cameraNode.position = SCNVector3(x: -3.0, y: 3.0, z: 3.0)
        
        for atom in molecule!.atom {
            let sphere = SCNSphere(radius: self.size)
            sphere.segmentCount = 30
            sphere.firstMaterial?.diffuse.contents = getAtomColor(element: atom.element)
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.position = SCNVector3(x: atom.x, y: atom.y, z: atom.z)
            
            scene.rootNode.addChildNode(sphereNode)
            sphereNodeDic[atom.id] = sphereNode
            
//            let constraint = SCNLookAtConstraint(target: sphereNode)
//            constraint.isGimbalLockEnabled = true
//            cameraNode.constraints = [constraint]
        }
        
        for conect in molecule!.conect {
            for (index, id) in conect.ids.enumerated() {
                if index == 0 {continue}

                guard let node1 = sphereNodeDic[conect.ids[0]]?.position else {continue}
                guard let node2 = sphereNodeDic[id]?.position else {continue}

                let cylinderNode = CylinderLine(parent: scene.rootNode, v1: node1, v2: node2, radius: 0.05, color: UIColor.white)
                scene.rootNode.addChildNode(cylinderNode)
                
                if molecule?.atom[id - 1].element == "H" {
                    hydrogeneCylinderNodeList.append(cylinderNode)
                }
            }
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
        sceneView.addGestureRecognizer(tap)
        
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.white
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        
        atomElementText.sizeToFit()
        atomElementText.backgroundColor = sceneView.backgroundColor
        atomElementText.isHidden = true
        if atomElementText.backgroundColor == UIColor.white
        {
            atomElementText.textColor = UIColor.black
        }
        else
        {
            atomElementText.textColor = UIColor.white
        }
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
