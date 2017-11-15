//
//  PuzzleGuess.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 5/21/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation
import RealmSwift

class PuzzleGuess: Object {
    let forPuzzle = LinkingObjects(fromType: PuzzleProgress.self, property: "puzzleGuesses")
    dynamic var cellId = 0
    var guess = RealmOptional<Int>()
}
