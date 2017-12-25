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
    @objc dynamic var puzzleSize = 0
    @objc dynamic var activePuzzleId = 0
    @objc dynamic var puzzleProgress: PuzzleProgress?
    @objc dynamic var pausedGameTimer = 0.0
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
    
    func setPausedGameTimer(to: Double, withRealm: Realm? = nil) {
        do {
            let realm = try withRealm ?? Realm()
            
            try realm.write {
                self.pausedGameTimer = to
            }
        } catch (let error) {
            fatalError("Error setting the paused game timer:\n\(error)")
        }
    }
}
