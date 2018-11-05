//
//  ListViewController.swift
//  Swifty Protein
//
//  Created by Jimmy CHEN-MA on 10/31/18.
//  Copyright © 2018 Jimmy CHEN-MA. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
    var list:[String] = []
    var searchList = [String]()
    var searching: Bool = false
    var loadingLigand: Bool = false
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    /*--------------------------------------*/
    /*---------------FUNCTION---------------*/
    /*--------------------------------------*/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if searching {
            return searchList.count
        } else {
            return list.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell") as! ListTableViewCell
        if searching {
            cell.displayName(name: searchList[indexPath.row])
        } else {
            cell.displayName(name: list[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if searching {
            self.getLigand(name: searchList[indexPath.row])
        } else {
            self.getLigand(name: list[indexPath.row])
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if (searchText != "") {
            searchList = list.filter({$0.range(of: searchText) != nil})
            searching = true
            tableView.reloadData()
        } else {
            searching = false
            tableView.reloadData()
        }
    }
    
    private func getLigand(name: String)
    {
        var ligand:[String] = []
        
        if !loadingLigand
        {
            loadingLigand = true
            guard let url = URL(string: "https://files.rcsb.org/ligands/view/" + name + "_ideal.pdb") else {
                return
            }
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                data, response, error in
                if let error = error {
                    print("Error", error)
                }
                else if let d = data {
                    let contents = String(data: d, encoding: String.Encoding.utf8)
                    contents?.enumerateLines(invoking: { (line, stop) -> () in
                        ligand.append(line)
                    })
                    var mole: MoleculeInfo = self.parsing(lig: ligand)
                    mole.name = name
                    if !mole.atom.isEmpty {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "moleculeSegue", sender: mole)
                        }
                    }
                    DispatchQueue.main.async {
                        self.loadingLigand = false
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
            }
            task.resume()
        }
    }
    
    private func parsing(lig: [String]) -> MoleculeInfo
    {
        var atom: [AtomInfo] = []
        var conect: [ConectInfo] = []
        
        if (lig[0].range(of: "ATOM") == nil) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: "Protein didn't found", preferredStyle:UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            return (MoleculeInfo(name: "", atom: [], conect: []))
        }
        else
        {
            let atomArray: [String] = lig.filter({$0.range(of: "ATOM") != nil})
            let conectArray: [String] = lig.filter({$0.range(of: "CONECT") != nil})
            
            for str in atomArray {
                let strArray = str.split(separator: " ")
                atom.append(AtomInfo(id: Int(strArray[1])!, x: Float(strArray[6])!, y: Float(strArray[7])!, z: Float(strArray[8])!, element: String(strArray[11])))
            }
            
            for str in conectArray {
                let strArray = str.split(separator: " ")
                var idsConection: ConectInfo = ConectInfo()
                var isSecond: Bool = false
                var firstId: Int = -1
                var isPresent: Bool = false

                for conection in strArray {
                    if conection == "CONECT" {
                        isSecond = true
                        continue
                    }
                    guard let id = Int(conection) else {continue}
                    if isSecond {
                        idsConection.ids.append(id)
                        isSecond = false
                        firstId = id
                    } else {
                        for conection in conect {
                            if isPresent {break}
                            var firstCurrentId = -1
                            for (index, currentId) in conection.ids.enumerated() {
                                if index == 0 {
                                    firstCurrentId = currentId
                                    continue
                                }
                                if firstId == currentId && firstCurrentId == id {
                                    isPresent = true
                                    break
                                }
                            }
                        }
                        if isPresent {
                            isPresent = false
                            continue
                        } else {
                            idsConection.ids.append(id)
                        }
                    }
                    
                }
                conect.append(idsConection)
            }
        }
        return (MoleculeInfo(name: "", atom: atom, conect: conect))
    }
    
    /*--------------------------------------*/
    /*---------------OVERRIDE---------------*/
    /*--------------------------------------*/
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moleculeSegue" {
            if let vc = segue.destination as? MoleculeViewController {
                vc.molecule = sender as? MoleculeInfo
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let file = Bundle.main.path(forResource: "list", ofType: "txt")
        {
            do
            {
                let str = try String(contentsOfFile: file, encoding: String.Encoding(rawValue: String.Encoding.ascii.rawValue))
                str.enumerateLines(invoking: { (line, stop) -> () in
                    self.list.append(line)
                })
            }
            catch let error as NSError
            {
                print ("Fail to read from file List.txt")
                print (error.debugDescription)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
