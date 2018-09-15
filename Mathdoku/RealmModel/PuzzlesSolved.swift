//
//  PuzzlesSolved.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 6/5/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation
import RealmSwift

class PuzzlesSolved: Object {
    let forPuzzleSize = LinkingObjects(fromType: PlayerProgress.self, property: "puzzlesSolved")
    @objc dynamic var puzzleId = 0
    @objc dynamic var solvedOn: NSDate? = nil
    // @objc dynamic var timeToSolve: Double? = nil
    let timeToSolve = RealmOptional<Double>()
    @objc dynamic var playCount = 0
    
    func markPuzzlePlayed(finalTime time: Double, withRealm: Realm? = nil) {
        do {
            let realm = try withRealm ?? Realm()
            
            let timeToSave: Double
            if let currentBestTime = self.timeToSolve.value {
                timeToSave = (currentBestTime < time ? currentBestTime : time)
            } else {
                timeToSave = time
            }
            
            try realm.write {
                self.solvedOn = NSDate()
                self.timeToSolve.value = timeToSave
                self.playCount = self.playCount + 1
            }
        } catch let error {
            error.report()
            fatalError("Error saving a new puzzle that has been completed:\n\(error)")
        }
    }
}
