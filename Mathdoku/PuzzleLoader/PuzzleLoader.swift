//
//  PuzzleLoader.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/10/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit

class PuzzleLoader {
    // hard coded number of puzzles available per JSON.
    // May want to calculate this later, but I set the file size for now.
    private let puzzlesPerFile = 4000
    
    // Saving JSON files that have been loaded into memory so they don't have to be loaded again
    private var loadedJSONS: Dictionary<String, JSON> = [:]
    private var loadedPuzzles: Dictionary<String, Puzzle> = [:]
    
    // ID Forming Closures
    private let createPuzzleId: (Int, Int) -> String = { (size, pId) in
        return "\(size)-\(pId)"
    }
    
    // Dispatch Queue for any puzzle loading and fetching. Needs to be sequel
    private let queue = DispatchQueue(label: "com.geissefamily.taylor.puzzleLoader", qos: .userInitiated)
    
    func preloadPuzzle(forSize size: Int, withPuzzleId pId: Int) {
        // create the puzzle Id used to identify the puzzle in the dictinoary
        let puzzleId = createPuzzleId(size, pId)
        
        queue.async { [weak self] in
            // track what puzzle sizes are getting preloaded.
            AnalyticsWrapper.logEvent(.selectContent, contentType: .puzzleLoad, id: "id-preloadPuzzle", name: "puzzleSize-\(size)", variant: "\(pId)")
            
            DebugUtil.print("Asked to preload a puzzle for size \(size) with id \(pId)")
            if self?.loadedPuzzles[puzzleId] == nil {
                DebugUtil.print("Preloading a puzzle for size \(size) with id \(pId)")
                // we don't have the puzzle loaded already
                self?.loadedPuzzles[puzzleId] = self?.loadPuzzleFromJson(forSize: size, withPuzzleId: pId)
                DebugUtil.print("Done preloading a puzzle for size \(size) with id \(pId)")
            }
        }
    }
    
    func fetchPuzzle(forSize size: Int, withPuzzleId pId: Int) -> Puzzle {
        var returnPuzzle: Puzzle!
        let puzzleId = createPuzzleId(size, pId)
        
        queue.sync {
            AnalyticsWrapper.logEvent(.selectContent, contentType: .puzzleLoad, id: "id-fetchPuzzle", name: "puzzleSize-\(size)", variant: "\(pId)")
            
            returnPuzzle = loadedPuzzles[puzzleId] ?? loadPuzzleFromJson(forSize: size, withPuzzleId: pId)
        }
        
        return returnPuzzle
    }
    
    private func loadPuzzleFromJson(forSize size: Int, withPuzzleId pId: Int) -> Puzzle {
        // create the resource Id, used for loading the resource and for storing the preloaded JSON
        let resourceId = "\(size)all-\(1 + (pId / puzzlesPerFile))"
        let relativePuzzleId = pId % puzzlesPerFile
        
        let puzzleJsonObj = loadedJSONS[resourceId] ?? loadJsonFromDataAsset(resourceName: resourceId)
        loadedJSONS[resourceId] = puzzleJsonObj
        let decompiledPuzzle = puzzleJsonObj["puzzles"][relativePuzzleId]
        
        if let solution = decompiledPuzzle["solution"].string,
            let cageGrid = decompiledPuzzle["cageGrid"].string,
            let cageOps = decompiledPuzzle["cageOps"].string {
            
            return parseNewPuzzleFromStrings(puzzleSize: size, puzzleSolution: solution, puzzleCageGrid: cageGrid, puzzleCages: cageOps)
        } else {
            return parseNewPuzzleFromStrings(puzzleSize: size, puzzleSolution: "", puzzleCageGrid: "", puzzleCages: "")
        }
    }
    
    private func loadJsonFromDataAsset(resourceName resource: String) -> JSON {
        let dataAsset = NSDataAsset(name: resource, bundle: Bundle.main)
        do {
            let jsonObj = try JSON(data: dataAsset!.data)
            return jsonObj
        } catch let error {
            fatalError("Unable to locate the asset with name \(resource) - \(error)")
        }
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
                let totalValue = Int(cage[totalIndex...])!
                
                if let cagesCells = cellsForCage[cageGroup] {
                    cages[cageGroup] = Cage(cells: cagesCells, total: totalValue, operation: operation)
                }
            }
        }
        
        return Puzzle(size: size, cells: cells, cages: cages)
    }
    
    // MARK: - Initiatlizers
    init() {
        NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidReceiveMemoryWarning, object: nil, queue: .main) { [weak self] notification in
            self?.loadedJSONS.removeAll(keepingCapacity: false)
            self?.loadedPuzzles.removeAll(keepingCapacity: false)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
