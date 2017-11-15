//
//  CellPosition.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 5/20/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation

struct CellPosition: Hashable {
    let row: Int
    let col: Int
    var position: (row: Int, col: Int) {
        return (self.row, self.col)
    }
    let cellId: Int
    let size: Int
    
    init(row: Int, col: Int, puzzleSize size: Int) {
        self.row = row
        self.col = col
        self.cellId = (row * size) + col
        self.size = size
    }
    
    init(cellId: Int, puzzleSize size: Int) {
        self.row = cellId / size
        self.col = cellId % size
        self.cellId = cellId
        self.size = size
    }
    /*
    static func +(leftHandSide: CellPosition, rightHandSide: Int) -> CellPosition {
        let newCellId = leftHandSide.cellId + rightHandSide
        return CellPosition(cellId: newCellId, puzzleSize: leftHandSide.size)
    }
    
    static func -(leftHandSide: CellPosition, rightHandSide: Int) -> CellPosition {
        let newCellId = leftHandSide.cellId - rightHandSide
        return CellPosition(cellId: newCellId, puzzleSize: leftHandSide.size)
    }*/
    
    var hashValue: Int {
        return self.cellId
    }
    
    static func == (lhs: CellPosition, rhs: CellPosition) -> Bool {
        return lhs.cellId == rhs.cellId
    }
}