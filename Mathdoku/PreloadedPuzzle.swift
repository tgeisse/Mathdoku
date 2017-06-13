//
//  PreloadedPuzzle.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 5/26/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation

struct PreloadedPuzzle: Hashable {
    let puzzleId: Int
    let solution: String
    let cageGrid: String
    let cageOps: String
    
    var hashValue: Int {
        return puzzleId
    }
    
    static func == (lhs: PreloadedPuzzle, rhs: PreloadedPuzzle) -> Bool {
        return lhs.puzzleId == rhs.puzzleId && lhs.solution == rhs.solution && lhs.cageGrid == rhs.cageGrid && lhs.cageOps == rhs.cageOps
    }
}
