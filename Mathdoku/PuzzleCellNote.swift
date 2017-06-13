//
//  PuzzleCellNote.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 5/21/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation
import RealmSwift

class PuzzleCellNote: Object {
    let forCell = LinkingObjects(fromType: PuzzleNote.self, property: "notes")
    dynamic var note = 0
    dynamic var possibility = 0
}
