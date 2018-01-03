//
//  MoveHistory.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 1/2/18.
//  Copyright © 2018 Taylor Geisse. All rights reserved.
//

import Foundation

// define what a move is - It's a cell position marked by an old value and a new value
typealias Move = (cell: CellPosition, from: Int?, to: Int?)

class MoveHistory {
    private var undoMoves = Stack<Move>()
    private var redoMoves = Stack<Move>()
    
    var undoCount: Int {
        return undoMoves.count
    }
    
    var redoCount: Int {
        return redoMoves.count
    }
    
    func makeMove(_ move: Move) {
        if move.from != move.to {
            undoMoves.push(move)
            redoMoves.removeAll()
        }
    }
    
    func undo() -> Move? {
        if let lastMove = undoMoves.pop() {
            redoMoves.push(lastMove)
            return lastMove
        } else {
            return nil
        }
    }
    
    func redo() -> Move? {
        if let nextMove = redoMoves.pop() {
            undoMoves.push(nextMove)
            return nextMove
        } else {
            return nil
        }
    }
    
    func reset() {
        undoMoves.removeAll()
        redoMoves.removeAll()
    }
}
