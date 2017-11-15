//
//  Cell.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/9/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation

struct Cell {
    let cage: String
    let answer: Int
    // var userNotes: 
    var userGuess: Int?
    
    init(cage c: String, answer a: Int, userGuess ug: Int? = nil) {
        cage = c
        answer = a
        userGuess = ug
    }
    
    var correctGuess: Bool {
        return userGuess == answer
    }
}
