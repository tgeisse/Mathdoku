//
//  PuzzleLoader.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/10/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit
import Firebase

enum PuzzleLoaderStatusCode {
    case success(Puzzle)
    case noPuzzleToLoad
    case error(String)
}

class PuzzleLoader {
    private let puzzlesPerFile = 4000
    private var preloadedPuzzles: Dictionary<Int, Set<PreloadedPuzzle>> = [:]
    
    class func getPuzzleForSize(_ size: Int, atPuzzleCount: Int) -> PuzzleLoaderStatusCode {
        return .error("Not implemented yet")
    }
    
    /// Preload a puzzle of a certain size given a puzzle ID. If a puzzle with the same puzzle ID is
    /// already preloaded, then this function will not load it a second time
    ///
    /// - Parameter size: the size of the puzzle grid
    /// - Parameter withPuzzleId: the puzzle ID to preload
    func preloadPuzzleForSize(_ size: Int, withPuzzleId pId: Int) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            DebugUtil.print("about to take the lock")
            objc_sync_enter(self)
            DebugUtil.print("took the lock")
            
            // let's track that the number was changed only when the user selected a size
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "id-loadPuzzle",
                AnalyticsParameterItemName: "puzzleSize-\(size)",
                AnalyticsParameterItemVariant: "\(pId)"
                ])
            
            if self?.preloadedPuzzles[size] == nil {
                self?.preloadedPuzzles[size] = Set()
            }
            
            if self?.preloadedPuzzles[size]?.filter({ $0.puzzleId == pId }).count == 0 {
                // we don't have a puzzle loaded yet for this pId, so let's do that
                if let newPuzzle = self?.loadNewPuzzleFromJSON(puzzleSize: size, withPuzzleId: pId) {
                    let puzzle = PreloadedPuzzle(puzzleId: pId,
                                                 solution: newPuzzle.solution,
                                                 cageGrid: newPuzzle.cageGrid,
                                                 cageOps: newPuzzle.cageOps)
                    
                    self?.preloadedPuzzles[size]?.insert(puzzle)
                }
            }
            
            DebugUtil.print("about to release the lock")
            objc_sync_exit(self)
            DebugUtil.print("released the lock")
        }
    }
    
    /// Loads a new puzzle, either from memory or new from the file, and returns a puzzle parsed object.
    ///
    /// - Parameters:
    ///   - size: the size of the puzzle grid
    ///   - pId: the puzzle ID to be loaded
    /// - Returns: the puzzle object
    func loadNewPuzzleForSize(_ size: Int, withPuzzleId pId: Int) -> Puzzle {
        let newPuzzle: (solution: String, cageGrid: String, cageOps: String)

        DebugUtil.print("about to take the lock")
        objc_sync_enter(self)
        DebugUtil.print("took the lock")
        
        let preloadedPuzzlesForSize = preloadedPuzzles[size]?.filter({ $0.puzzleId == pId })
        
        if preloadedPuzzlesForSize?.count != 0, let puzzleForId = preloadedPuzzlesForSize?[0] {
            // if we have a preloaded puzzle with our puzzle ID, then we can use that
            DebugUtil.print("Loading a pre-loaded puzzle for pid: \(pId)")
            newPuzzle = (puzzleForId.solution, puzzleForId.cageGrid, puzzleForId.cageOps)
        } else {
            // otherwise, load a new one
            DebugUtil.print("Loading a new puzzle for pid: \(pId)")
            newPuzzle = loadNewPuzzleFromJSON(puzzleSize: size, withPuzzleId: pId)!
        }
        
        DebugUtil.print("about to release the lock")
        objc_sync_exit(self)
        DebugUtil.print("released the lock")
        
        return parseNewPuzzleFromStrings(puzzleSize: size, puzzleSolution: newPuzzle.solution, puzzleCageGrid: newPuzzle.cageGrid, puzzleCages: newPuzzle.cageOps)
    }
    
    /// Purges all preloaded puzzles.
    func purgePreloadedPuzzles() {
        for key in preloadedPuzzles.keys {
            preloadedPuzzles[key]! = Set()
        }
    }
    
    /// This function will load the puzzle from a JSON file.
    ///
    /// - Parameters:
    ///   - size: the size the puzzle grid
    ///   - pId: the puzzle ID to load
    /// - Returns: the puzzle represented as flat strings
    private func loadNewPuzzleFromJSON(puzzleSize size: Int, withPuzzleId pId: Int) -> (solution: String, cageGrid: String, cageOps: String)? {
        let puzzleResource = "\(size)all-1"
        
        DebugUtil.print("Entering JSON loader and attempting to load json: \(puzzleResource) @ \(pId)")
        
        if let asset = NSDataAsset(name: puzzleResource, bundle: Bundle.main) {
            do {
                let jsonObj = try JSON(data: asset.data)
                let puzzle = jsonObj["puzzles"][pId]
                
                if let solution = puzzle["solution"].string, let cageGrid = puzzle["cageGrid"].string, let cageOps = puzzle["cageOps"].string {
                    return (solution, cageGrid, cageOps)
                }
            } catch let error {
                DebugUtil.print(error.localizedDescription)
            }
        }
        
        return nil
    }
    
    /// Given a flat representation of a puzzle, this function will parse the strings into a Puzzle object.
    /// Warning: this expects that the string are in a certain format. If they are not, then this function may fail.
    ///
    /// - Parameters:
    ///   - size: the size of the puzzle grid
    ///   - puzzleSolution: the flat puzzle solution as a string
    ///   - puzzleCageGrid: the flat puzzle cage grid as a string
    ///   - puzzleCages: the flat puzzle cages as a string
    /// - Returns: the Puzzle object
    private func parseNewPuzzleFromStrings(puzzleSize size: Int, puzzleSolution: String, puzzleCageGrid: String, puzzleCages: String) -> Puzzle {
        
        let totalCells = size * size
        var cells = [Cell]()
        var cages = Dictionary<String, Cage>()
        var cellsForCage = Dictionary<String, [Int]>()
        
        // parse the solution and cage grid into the cells
        for cellId in 0..<totalCells {
            let solutionIndex = puzzleSolution.index(puzzleSolution.startIndex, offsetBy: cellId)
            let cageGridIndex = puzzleCageGrid.index(puzzleCageGrid.startIndex, offsetBy: cellId)
            
            let cage = String(puzzleCageGrid[cageGridIndex])
            let solution = Int(String(puzzleSolution[solutionIndex]))!
            
            cells.append(Cell(cage: cage, answer: solution))
            
            if cellsForCage[cage] != nil {
                cellsForCage[cage]!.append(cellId)
            } else {
                cellsForCage[cage] = [cellId]
            }
        }
        
        // parse the cages
        for cage in puzzleCages.components(separatedBy: " ") {
            if cage.count >= 3 {
                let cageIndex = cage.index(cage.startIndex, offsetBy: 0)
                let operationIndex = cage.index(cage.startIndex, offsetBy: 1)
                let totalIndex = cage.index(cage.startIndex, offsetBy: 2)
                
                let cageGroup = String(cage[cageIndex])
                let operation = String(cage[operationIndex])
                let totalValue = Int(String(cage.substring(from: totalIndex)))!
                
                if let cagesCells = cellsForCage[cageGroup] {
                    cages[cageGroup] = Cage(cells: cagesCells, total: totalValue, operation: operation)
                }
            }
        }
        
        return Puzzle(size: size, cells: cells, cages: cages)

    }

}
