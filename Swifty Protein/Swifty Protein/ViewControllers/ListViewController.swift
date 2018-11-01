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
    var ligand:[String] = []
    var searchList = [String]()
    var searching:Bool = false
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    /*--------------------------------------*/
    /*---------------FUNCTION---------------*/
    /*--------------------------------------*/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if searching
        {
            return searchList.count
        }
        else
        {
            return list.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell") as! ListTableViewCell
        if searching
        {
            cell.displayName(name: searchList[indexPath.row])
        }
        else
        {
            cell.displayName(name: list[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searching {
            self.getLigand(name: searchList[indexPath.row])
        } else {
            self.getLigand(name: list[indexPath.row])
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        searchList = list.filter({$0.range(of: searchText) != nil})
        searching = true
        tableView.reloadData()
    }
    
    private func getLigand(name: String) {
        let url = URL(string: "https://files.rcsb.org/ligands/view/" + name + "_ideal.pdb")
        // TODO if url is null ca crash
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            if let error = error {
                print("1", error)
            }
            else if let d = data {
                let contents = String(data: d, encoding: String.Encoding.utf8)
                contents?.enumerateLines(invoking: { (line, stop) -> () in
                    self.ligand.append(line)
                })
                print(self.ligand)
                
                
                performSegue(withIdentifier: <#T##String#>, sender: <#T##Any?#>)

            }
        }
        task.resume()
    }
    
    /*--------------------------------------*/
    /*---------------OVERRIDE---------------*/
    /*--------------------------------------*/
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "moleculeSegue"
        {
            if let vc = segue.destination as? MoleculeViewController
            {
                if let cell = sender as? ListTableViewCell
                {
                    vc.moleculeName = cell.moleculeName.text!
                }
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
