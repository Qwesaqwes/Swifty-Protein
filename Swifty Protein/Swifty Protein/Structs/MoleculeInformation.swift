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
    var id1:Int         // ids of which the tube is conected
    var id2:Int
    var id3:Int
    var id4:Int
    var id5:Int
}

struct MoleculeInfo
{
    var atom:[AtomInfo] = []
    var conect:[ConectInfo] = []
}
