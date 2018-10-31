//
//  ListTableViewCell.swift
//  Swifty Protein
//
//  Created by Jimmy CHEN-MA on 10/31/18.
//  Copyright © 2018 Jimmy CHEN-MA. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var moleculeName: UILabel!
    
    
    func displayName(name:String)
    {
        moleculeName.text = name
    }
}
