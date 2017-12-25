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
    @objc dynamic var solvedOn = NSDate()
    @objc dynamic var timeToSolve = 0.0
}
