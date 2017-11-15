//
//  PlayerProgress.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 5/18/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation
import RealmSwift

class PlayerProgress: Object {
    dynamic var puzzleSize = 0
    dynamic var activePuzzleId = 0
    dynamic var puzzleProgress: PuzzleProgress?
    let puzzlesSolved = List<PuzzlesSolved>()
    
    override static func primaryKey() -> String? {
        return "puzzleSize"
    }
    
    func incrementPuzzleId(withRealm: Realm? = nil) {
        do {
            let realm = try withRealm ?? Realm()
            
            try realm.write {
                self.activePuzzleId = self.activePuzzleId + 1
            }
        } catch (let error) {
            fatalError("Error incrementing puzzle id:\n\(error)")
        }
    }
}
