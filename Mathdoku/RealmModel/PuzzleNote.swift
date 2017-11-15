//
//  PuzzleNote.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 5/21/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation
import RealmSwift

class PuzzleNote: Object {
    let forPuzzle = LinkingObjects(fromType: PuzzleProgress.self, property: "puzzleNotes")
    dynamic var cellId = 0
    let notes = List<PuzzleCellNote>()
}
