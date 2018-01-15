//
//  MoveHistory.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 1/2/18.
//  Copyright © 2018 Taylor Geisse. All rights reserved.
//

import Foundation

// define what a move is - It's a cell position marked by a MoveType
typealias Move = (cell: CellPosition, moveType: MoveType)

enum MoveType {
    case note(number: Int, fromPossibility: Int, toPossibility: Int)
    case guess(from: Int?, to: Int?)
}

enum MoveDirection {
    case undo
    case redo
}

class MoveHistory {
    private var undoMoves = Stack<[Move]>(maxSize: 1000)
    private var redoMoves = Stack<[Move]>(maxSize: 1000)
    
    var undoCount: Int {
        return undoMoves.count
    }
    
    var redoCount: Int {
        return redoMoves.count
    }
    
    func makeMoves(_ moves: [Move]) {
        undoMoves.push(moves)
        redoMoves.removeAll()
    }
    
    func undo() -> [Move]? {
        if let lastMove = undoMoves.pop() {
            redoMoves.push(lastMove)
            return lastMove
        } else {
            return nil
        }
    }
    
    func redo() -> [Move]? {
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
