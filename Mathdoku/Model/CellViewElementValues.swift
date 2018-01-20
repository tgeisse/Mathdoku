//
//  CellViewElementValues.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 1/19/18.
//  Copyright © 2018 Taylor Geisse. All rights reserved.
//

import UIKit

class CellViewElementValues {
    static let sharedInstance = CellViewElementValues()
    
    // note elements
    var noteFont: UIFont? = nil
    var noteTextSize: CGSize? = nil
    var notePositionX: CGFloat? = nil
    var notePositionY: CGFloat? = nil
    
    // guess elements
    var guessFont: UIFont? = nil
    var guessTextSize: CGSize? = nil
    var guessConflictShadow: NSShadow? = nil
    var guessEqualShadow: NSShadow? = nil
    var guessPositionX: CGFloat? = nil
    var guessPositionY: CGFloat? = nil
    
    // hint elements
    var hintFont: UIFont? = nil
    
    func clear() {
        // reset note elements
        noteFont = nil
        noteTextSize = nil
        notePositionX = nil
        notePositionY = nil
        
        // reset guess elements
        guessFont = nil
        guessTextSize = nil
        guessConflictShadow = nil
        guessEqualShadow = nil
        guessPositionX = nil
        guessPositionY = nil
        
        // reset hint elements
        hintFont = nil
    }
}
