//
//  MoleculeInformation.swift
//  Swifty Protein
//
//  Created by Jimmy CHEN-MA on 11/1/18.
//  Copyright © 2018 Jimmy CHEN-MA. All rights reserved.
//

import Foundation

struct AtomInfo
{
    var id:Int          // ID of atom
    var x:Float         // x Coordinate
    var y:Float         // y Coordinate
    var z:Float         // z Coordinate
    var element:String  // element of Atom
}

struct ConectInfo
{
    var ids: [Int] = [] // ids of which the tube is conected
}

struct MoleculeInfo
{
    var name: String = ""
    var atom :[AtomInfo] = []
    var conect :[ConectInfo] = []
}
