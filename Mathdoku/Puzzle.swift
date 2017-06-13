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
        if cells.isEmpty {
            return false
        }
        
        if cells.filter( { $0.userGuess != nil }).count != cells.count {
            return false
        }
        
        for cell in cells {
            if cell.correctGuess == false {
                return false
            }
        }
        
        return true
    }
    
    init(size puzzleSize: Int, cells puzzleCells: [Cell], cages puzzleCages: Dictionary<String, Cage>) {
        size = puzzleSize
        cells = puzzleCells
        cages = puzzleCages
    }
    
    func cellIsGuessedAtPosition(_ cellPosition: CellPosition) -> Bool {
        return cells[cellPosition.cellId].userGuess != nil
    }
    
    private func setGuessForCellId(_ cellId: Int, guess: Int?) {
        cells[cellId].userGuess = guess
    }
    
    func setGuessForCellPosition(_ cellPosition: CellPosition, guess: Int?) {
        setGuessForCellId(cellPosition.cellId, guess: guess)
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
    /*
    func friendlyCellIdsForCellPosition(_ cellPosition: (Int, Int)) -> [Int]? {
        return friendlyCellIdsForCellId(cellIdForPosition(cellPosition))
    }
    
    private func friendlyCellIdsForCellId(_ cellId: Int) -> [Int]? {
        var friendlyCells = cages[cells[cellId].cage]?.cells
        
        if friendlyCells != nil {
            for index in 0..<friendlyCells!.count {
                if friendlyCells![index] == cellId {
                    friendlyCells!.remove(at: index)
                    break
                }
            }
        }
        
        return friendlyCells
    }
    */
    func getFriendliesForCell(_ cell: CellPosition) -> [CellPosition] {
        let friendlyCells = cages[cells[cell.cellId].cage]?.cells
        var friendlyPositions = [CellPosition]()
        
        if friendlyCells != nil {
            for friendlyCell in friendlyCells! {
                if friendlyCell != cell.cellId {
                    friendlyPositions.append(CellPosition(cellId: friendlyCell, puzzleSize: size))
                }
            }
        }
        
        return friendlyPositions
    }
    
    /*
    func neighborsInSameCageForCellAtPosition(_ cellPosition: (Int, Int)) -> (north: Bool, east: Bool, south: Bool, west: Bool)? {
    
        return neighborsInSameCageForCell(cellIdForPosition(cellPosition))
    }
 */
    
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
    
    
    /*
     private func getCellIdsForCageGroupOfCellId(_ cellId: Int) -> [Int]? {
     if cellId > cells.endIndex || cellId < cells.startIndex {
     return nil
     } else {
     return cages[cells[cellId].cage]?.cells
     }
     }
     
     private func cellIdForPosition(_ cellPosition: (row: Int, col: Int)) -> Int {
     return (cellPosition.row * size) + cellPosition.col
     }
     */
    
    
}
