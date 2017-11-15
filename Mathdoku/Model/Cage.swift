//
//  Cage.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/10/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation

struct Cage {
    let cells: [Int]
    let total: Int
    let operation: String
    
    var firstCell: Int {
        return cells[0]
    }
    
    //
    var hintText: String {
        if operation == "_" {
            return "\(total)"
        } else {
            return "\(total)\(operation)"
        }
    }
}
