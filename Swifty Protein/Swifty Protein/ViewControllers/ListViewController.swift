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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        searchList = list.filter({$0.range(of: searchText) != nil})
        searching = true
        tableView.reloadData()
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
