//
//  PuzzleLoader.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/10/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit
import RealmSwift

class PuzzleLoader {
    static let sharedInstance = PuzzleLoader()
    
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
    private let queue = DispatchQueue(label: "\(AppSecrets.domainRoot).puzzleLoader", qos: .userInitiated)
    
    // MARK: - Public API
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
    
    func getNextPuzzleId(forSize size: Int) -> Int {
        let realm: Realm
        do {
            try realm = Realm()
        } catch let error {
            error.report()
            fatalError("Could not open a Realm connection:\n\(error)")
        }
        
        // get set of available puzzle IDs
        let assetCount = availableJsonAssets(forSize: size)
        let allPuzzleIds = Set(0..<puzzlesPerFile * assetCount)
        DebugUtil.print("Identified \(assetCount) JSONs for size \(size), resulting in \(allPuzzleIds.count) puzzles")
        
        // get the List of PuzzlesSolved - create an empty list on the VERY unlikely chance this is nil
        let puzzlesSolved = realm.objects(PlayerProgress.self).filter("puzzleSize == \(size)").first?.puzzlesSolved ?? List<PuzzlesSolved>()
        DebugUtil.print("Found \(puzzlesSolved.count) previously played puzzles")
        
        // get the lowest play count - set it to 0 if nil
        let lowestPlayCount: Int
        if puzzlesSolved.count != allPuzzleIds.count {
            // if the user hasn't played through all of the puzzles, then the lowestPlayCount is 0
            lowestPlayCount = 0
        } else {
            // if the user has played through all puzzles, then look up the lowest play count
            lowestPlayCount = puzzlesSolved.min(ofProperty: "playCount") as Int? ?? Int.max
        }
        DebugUtil.print("Lowest play count: \(lowestPlayCount)")
        
        // look up all of the puzzles played that are at or above the current low play count - one of these is the exclusion list
        let playsAboveLowPlayCount = Array(puzzlesSolved.filter("playCount > \(lowestPlayCount)"))
        
        // exclude any puzzle with a play count greater than the lowest play count
        let excludePuzzleIds = Set(playsAboveLowPlayCount.map { $0.puzzleId })
        DebugUtil.print("Excluding \(excludePuzzleIds.count) puzzleIds from the available puzzles")
        
        // subtract the excuded puzzle iDs
        let availablePuzzleIds = Array(allPuzzleIds.subtracting(excludePuzzleIds))
        
        // get a random puzzle ID from the available puzzle IDs and return it
        return availablePuzzleIds[Int(arc4random_uniform(UInt32(availablePuzzleIds.count)))]
    }
    
    @available(*, deprecated, message: "Moving towards getNextPuzzleId function", renamed: "getNextPuzzleId")
    func getRandomPuzzleId(forSize size: Int) -> Int? {
        let realm = try! Realm()
        
        // get the PuzzlesSolved list from the PlayerProgress
        guard let puzzlesSolved = realm.objects(PlayerProgress.self).filter("puzzleSize == \(size)").first?.puzzlesSolved else {
            return nil
        }
        
        // get the lowest play count
        guard let lowestPlayCount = puzzlesSolved.min(ofProperty: "playCount") as Int? else {
            return nil
        }
        DebugUtil.print("For puzzle size \(size), the lowest number of played games is \(lowestPlayCount)")
        
        // get the play history objects with the same play count
        let availablePuzzles = puzzlesSolved.filter("playCount == \(lowestPlayCount)")
        DebugUtil.print("Found \(availablePuzzles.count) puzzles with the play count of \(lowestPlayCount)")
        
        // get a random puzzle from the list
        let randomPuzzleId = Int(arc4random_uniform(UInt32(availablePuzzles.count)))
        
        // return the puzzle ID for that random puzzle
        return availablePuzzles[randomPuzzleId].puzzleId
    }
    
    @available(*, deprecated, message: "Moving away from pre-loading and the loading screen")
    func loadPuzzleSolvedDefaultHistory(notify: (() -> Void)? = nil) {
        let realm = try! Realm()
        
        for size in 3...9 {
            // for first timers, this should be all we need
            let assetCount = availableJsonAssets(forSize: size)
            let availablePuzzleIds = Set(0..<puzzlesPerFile * assetCount)
            DebugUtil.print("Identified \(assetCount) JSONs for size \(size), resulting in \(availablePuzzleIds.count) puzzles")
            
            // identify already played puzzles, since their records are already in Realm
            let puzzleListForSize = realm.objects(PlayerProgress.self).filter("puzzleSize == \(size)").first!.puzzlesSolved
            let playedIds = puzzleListForSize.map {
                $0.puzzleId
            }
            DebugUtil.print("Found \(playedIds.count) previously added puzzleIds")
            
            // subtract the puzzles already solved from the available puzzles to get the set that needs to be added to realm
            let puzzlesToAdd = availablePuzzleIds.subtracting(playedIds)
            DebugUtil.print("Need to add \(puzzlesToAdd.count) puzzle IDs")
            
            if puzzlesToAdd.count > 0 {
                DebugUtil.print("Starting to add new puzzle history for size \(size)")
                do {
                    try realm.write {
                        puzzlesToAdd.forEach {
                            let newElement = PuzzlesSolved()
                            newElement.puzzleId = $0
                            puzzleListForSize.append(newElement)
                        }
                    }
                } catch let error {            
                    error.report()
                    fatalError("Unable to write the new puzzles to realm:\n\(error)")
                }
                DebugUtil.print("Done adding puzzle history for size \(size)")
            }
            
            // notify the listener if there is one
            notify?()
        }
    }
    
    // MARK: - Private API
    private func availableJsonAssets(forSize size: Int) -> Int {
        var count = 0
        var searching = true
        
        while searching {
            let assetName = "\(size)all-\(count + 1)"
            if NSDataAsset(name: assetName, bundle: Bundle.main) != nil {
                count += 1
            } else {
                searching = false
            }
        }
        
        return count
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
            error.report()
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
