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
    case Note(number: Int, fromPossibility: Int?, toPossibility: Int?)
    indirect case Guess(from: Int?, to: Int?, affectedNotes: [MoveType]?)
}

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
        let saveMove: Bool
        
        switch move.moveType {
        case let .Guess(from, to, _) :
            saveMove = from != to
        default:
            saveMove = true
        }
        
        if saveMove {
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
