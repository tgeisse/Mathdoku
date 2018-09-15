//
//  PuzzleProgress.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 5/21/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation
import RealmSwift

class PuzzleProgress: Object {
    let puzzleGuesses = List<PuzzleGuess>()
    let puzzleNotes = List<PuzzleNote>()
    @objc dynamic var inProgress = false
    
    func setInProgress(to: Bool, withRealm: Realm? = nil) {
        do {
            let realm = try withRealm ?? Realm()
            
            try realm.write {
                self.inProgress = to
            }
        } catch let error {
            error.report()
            fatalError("Error setting puzzle inProgress:\n\(error)")
        }

    }
}
