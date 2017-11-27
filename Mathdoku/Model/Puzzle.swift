//
//  Puzzle.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/9/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation

class Puzzle {
    let size: Int
    let cages: Dictionary<String, Cage>
    private var cells: [Cell]
    
    var isSolved: Bool {
        // if we somehow have an empty array, then return false
        // an empty array is a very bad thing and really should never happen, but we should check
        if cells.isEmpty {
            return false
        }
        
        return cells.filter { $0.correctGuess } .count == cells.count
    }
    
    init(size puzzleSize: Int, cells puzzleCells: [Cell], cages puzzleCages: Dictionary<String, Cage>) {
        size = puzzleSize
        cells = puzzleCells
        cages = puzzleCages
    }
    
    func getUnitCellsWithAnswers() -> [(cell: CellPosition, answer: Int)] {
        var returnValue: [(cell: CellPosition, answer: Int)] = []
        
        cages.values.filter({ $0.operation == "_" }).forEach { cage in
            returnValue.append(
                (CellPosition(cellId: cage.firstCell, puzzleSize: self.size),
                 cage.total)
            )
        }
        
        return returnValue
    }
    
    func answerForPosition(_ cellPosition: CellPosition) -> Int {
        return cells[cellPosition.cellId].answer
    }
    
    func cellIsGuessedAtPosition(_ cellPosition: CellPosition) -> Bool {
        return cells[cellPosition.cellId].userGuess != nil
    }
    
    /// Sets the guess for a cell at a given cell position. Setting the guess to nil will clear the current value.
    ///
    /// - Parameters:
    ///   - cellPosition: location of the cell
    ///   - guess: guess being saved. nil will erase the entry
    func setGuessForCellPosition(_ cellPosition: CellPosition, guess: Int?) {
        cells[cellPosition.cellId].userGuess = guess
    }
    
    func identifyConflictingGuesses() -> [CellPosition] {
        var conflictingCellPositions: Set<CellPosition> = []
        
        for i in 1...size {
            let cellPosWithGuess = identifyCellsWithGuess(i)
            var rowCells: Dictionary<Int, Set<CellPosition>> = [:]
            var colCells: Dictionary<Int, Set<CellPosition>> = [:]
            
            for cellPos in cellPosWithGuess {
                var rowSet = rowCells[cellPos.row] ?? []
                var colSet = colCells[cellPos.col] ?? []
                
                rowSet.insert(cellPos)
                colSet.insert(cellPos)
                
                rowCells[cellPos.row] = rowSet
                colCells[cellPos.col] = colSet
                
                if rowSet.count > 1 {
                    conflictingCellPositions = conflictingCellPositions.union(rowSet)
                }
                if colSet.count > 1 {
                    conflictingCellPositions = conflictingCellPositions.union(colSet)
                }
            }
        }
        
        return Array(conflictingCellPositions)
    }
    
    func identifyCellsWithGuess(_ guess: Int) -> [CellPosition] {
        return cells.enumerated().filter { $0.element.userGuess == guess } .map { CellPosition(cellId: $0.offset, puzzleSize: size) }
    }
    
    func identifyCellsWithSameGuessAsCell(_ cell: CellPosition) -> [CellPosition] {
        if let guess = cells[cell.cellId].userGuess {
            return identifyCellsWithGuess(guess)
        } else {
            return []
        }
    }
    
    func getGuessedCellPositionsWithGuessValidation() -> [(cellPosition: CellPosition, correctGuess: Bool)] {
        var guessedCellPositionsWithGuessValidation = [(cellPosition: CellPosition, correctGuess: Bool)]()
        
        for (index, cell) in cells.enumerated() {
            if cell.userGuess != nil {
                let position = CellPosition(cellId: index, puzzleSize: size)
                let guessIsCorrect = cell.userGuess! == cell.answer
                
                guessedCellPositionsWithGuessValidation.append((position, guessIsCorrect))
            }
        }
        
        return guessedCellPositionsWithGuessValidation
    }
    
    func getUnguessedCellPositionsWithAnswers() -> [(cellPosition: CellPosition, answer: Int)] {
        var ungessedCells: [(cellPosition: CellPosition, answer: Int)] = []
        
        for (index, cell) in cells.enumerated() {
            if cell.userGuess == nil {
                ungessedCells.append((CellPosition(cellId: index, puzzleSize: size), cell.answer))
            }
        }
        
        return ungessedCells
    }
    
    func getFriendliesForCell(_ cell: CellPosition) -> [CellPosition] {
        var friendlyPositions = [CellPosition]()
        
        if let friendlyCells = cages[cells[cell.cellId].cage]?.cells {
            for friendlyCell in friendlyCells {
                if friendlyCell != cell.cellId {
                    friendlyPositions.append(CellPosition(cellId: friendlyCell, puzzleSize: size))
                }
            }
        }
        
        return friendlyPositions
    }
    
    func getUnfilledFriendliesForCell(_ cell: CellPosition) -> [CellPosition] {
        var unfilledFriendlyPositions = [CellPosition]()
        
        if let friendlyCells = cages[cells[cell.cellId].cage]?.cells {
            for friendlyCell in friendlyCells {
                if cells[friendlyCell].userGuess == nil {
                    unfilledFriendlyPositions.append(CellPosition(cellId: friendlyCell, puzzleSize: size))
                }
            }
        }
        
        return unfilledFriendlyPositions
    }
    
    func neighborsInSameCageForCell(_ cellPosition: CellPosition) -> (north: Bool, east: Bool, south: Bool, west: Bool)? {
        
        let cellId = cellPosition.cellId
        
        if cellId < cells.endIndex && cellId >= 0 {
            var startCellsNeighbors = (north: false, east: false, south: false, west: false)
            
            let startCellCage = cells[cellId].cage
            
            let cellToTheNorth = cellId - size
            let cellToTheEast = cellId + 1
            let cellToTheWest = cellId - 1
            let cellToTheSouth = cellId + size
            
            // check north
            startCellsNeighbors.north = (cellToTheNorth >= 0) && (cells[cellToTheNorth].cage == startCellCage)
            
            // check east
            startCellsNeighbors.east = (cellToTheEast < cells.endIndex) && (cells[cellToTheEast].cage == startCellCage) && (positionForCell(cellToTheEast).row == cellPosition.row)
            
            // check south
            startCellsNeighbors.south = (cellToTheSouth < cells.endIndex) && (cells[cellToTheSouth].cage == startCellCage)
            
            // check west
            startCellsNeighbors.west = (cellToTheWest >= 0) && (cells[cellToTheWest].cage == startCellCage) && (positionForCell(cellToTheWest).row == cellPosition.row)
            
            return startCellsNeighbors
        } else {
            return nil
        }
    }
    
    private func positionForCell(_ cell: Int) -> (row: Int, col: Int) {
        return (cell / size, cell % size)
    }
}
