//
//  CellPosition.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 5/20/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation

struct CellPosition: Hashable, Equatable {
    let row: Int
    let col: Int
    var position: (row: Int, col: Int) {
        return (self.row, self.col)
    }
    let cellId: Int
    let size: Int
    
    var isValid: Bool {
        return row < size && col < size && row >= 0 && col >= 0
    }
    
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
    
    func relativeCell(byRow: Int = 0, byCol: Int = 0) -> CellPosition? {
        return relativeCell(toRow: row + byRow, toCol: col + byCol)
        /*
        let relativeCol = col + byCol
        let relativeRow = row + byRow
        
        if relativeCol < 0 || relativeCol >= size || relativeRow < 0 || relativeRow >= size { return nil }
        else { return CellPosition(row: relativeRow, col: relativeCol, puzzleSize: self.size) }
         */
    }
    
    func relativeCell(toRow: Int) -> CellPosition? {
        return relativeCell(toRow: toRow, toCol: self.col)
    }
    
    func relativeCell(toCol: Int) -> CellPosition? {
        return relativeCell(toRow: self.row, toCol: toCol)
    }
    
    func relativeCell(toRow: Int, toCol: Int) -> CellPosition? {
        guard toRow >= 0 && toRow < size && toCol >= 0 && toCol < size else { return nil }
        return CellPosition(row: toRow, col: toCol, puzzleSize: size)
    }
    
    func neighborCell(inDirection direction: KeyboardDirection, atEnd toEnd: Bool = false) -> CellPosition? {
        switch direction {
        case .up: return toEnd ? relativeCell(toRow: 0) : relativeCell(byRow: -1)
        case .down: return toEnd ? relativeCell(toRow: size - 1) : relativeCell(byRow: 1)
        case .left: return toEnd ? relativeCell(toCol: 0) : relativeCell(byCol: -1)
        case .right: return toEnd ? relativeCell(toCol: size - 1) : relativeCell(byCol: 1)
        }
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.cellId)
    }
    
    static func == (lhs: CellPosition, rhs: CellPosition) -> Bool {
        return lhs.cellId == rhs.cellId
    }
}
