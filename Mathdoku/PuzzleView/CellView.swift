//
//  CellView.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/22/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

/** TODO:
* Potential fix for corners is to draw a square in the corner of size
* of the lines when there is a corner that would present such an issue.
* This is basically when 2 of the 4 that interconnect are foes while
* the other two are friends. Then that would require a drawing of a square
*/

/** TODO:
* Old code - make CellViews use more standard swift items. For example,
* using labels instead of drawing text for guesses and notes.
 */

import UIKit
import SwiftyUserDefaults

//@IBDesignable
class CellView: UIView {
    // MARK: Public Properties
    @IBInspectable var hint: String? { didSet { if oldValue != hint { setNeedsDisplay() } } }
    @IBInspectable var note: String? { didSet { if oldValue != note { setNeedsDisplay() } } }
    @IBInspectable var guess: String? { didSet { if oldValue != guess { setNeedsDisplay() } } }
    var topBorder: CellAllegiance = .other { didSet { if oldValue != topBorder { setNeedsDisplay() } } }
    var bottomBorder: CellAllegiance = .other { didSet { if oldValue != bottomBorder { setNeedsDisplay() } } }
    var rightBorder: CellAllegiance = .other { didSet { if oldValue != rightBorder { setNeedsDisplay() } } }
    var leftBorder: CellAllegiance = .other { didSet { if oldValue != leftBorder { setNeedsDisplay() } } }
    var topLeftCornerPatch = false { didSet { if oldValue != topLeftCornerPatch { setNeedsDisplay() } } }
    var topRightCornerPatch = false { didSet { if oldValue != topRightCornerPatch { setNeedsDisplay() } } }
    var bottomRightCornerPatch = false { didSet { if oldValue != bottomRightCornerPatch { setNeedsDisplay() } } }
    var bottomLeftCornerPatch = false { didSet { if oldValue != bottomLeftCornerPatch { setNeedsDisplay() } } }
    private var guessAllegiance: UInt8 = 0 { didSet { if oldValue != guessAllegiance { setNeedsDisplay() } } }
    var colorTheme = ColorTheme.sharedInstance
    
    enum CellAllegiance {
        case friend
        case foe
        case other
        
        var borderWeight: CGFloat {
            switch self {
            case .friend: return 0.18
            case .foe: return 1.15
            case .other: return 1.3
            }
        }
        
        @available(*, deprecated, message: "Moving to a function color scheme to allow overriding")
        var borderColor: UIColor {
            switch self {
            case .friend: return .darkGray
            case .foe: return .darkGray
            case .other: return .darkGray
            }
        }
    }
    
    func getCellAllegianceColor(_ allegiance: CellAllegiance) -> UIColor {
        switch allegiance {
        case .friend: return colorTheme.border
        case .foe: return colorTheme.border
        case .other: return colorTheme.border
        }
    }
    
    enum GuessAllegiance: UInt8 {
        case equal      = 0b000000001
        case conflict   = 0b000000010
        
        @available(*, deprecated, message: "Moving to a function color scheme to allow overriding")
        var shadowColor: UIColor {
            switch self {
            case .equal: return ColorTheme.sharedInstance.allegianceEqual
            case .conflict: return ColorTheme.sharedInstance.allegianceConflict
            }
        }
    }
    
    func getGuessAllegianceColor(_ allegiance: GuessAllegiance) -> UIColor {
        switch allegiance {
        case .equal: return colorTheme.allegianceEqual
        case .conflict: return colorTheme.allegianceConflict
        }
    }
    
    func hasGuessAllegiance(_ allegiance: GuessAllegiance) -> Bool {
        return guessAllegiance & allegiance.rawValue > 0
    }
    
    func addGuessAllegiance(_ allegiance: GuessAllegiance) {
        guessAllegiance = guessAllegiance | allegiance.rawValue
    }
    
    func removeGuessAllegiance(_ allegiance: GuessAllegiance) {
        guessAllegiance = guessAllegiance & ~allegiance.rawValue
    }
    
    func toggleGuessAllegiance(_ allegiance: GuessAllegiance) {
        guessAllegiance = guessAllegiance ^ allegiance.rawValue
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        self.isUserInteractionEnabled = false
        self.backgroundColor = .clear
        self.layer.sublayers?.removeAll()
        
        if CellViewElementValues.sharedInstance.scaleFactor == nil {
            CellViewElementValues.sharedInstance.scaleFactor = bounds.maxX / 100
        }
        
        // Add the borders around the cell
        addBorders()
        
        // patch corners
        patchCorners()
        
        // Add the hint text, if there is one
        addHintText()
        
        // Add the guess text, if there is one
        addGuessText()
        
        // Add the note text, if there is one
        addNotesText()
    }
    
    private func addHintText() {
        if hint == nil {
            // return if there is not hint text to render
            return
        }
        
        if CellViewElementValues.sharedInstance.hintFont == nil {
            CellViewElementValues.sharedInstance.hintFont =
                UIFont(name: "Verdana", size: CellViewElementValues.sharedInstance.hintDefaultTextSize * CellViewElementValues.sharedInstance.scaleFactor!)
                ??
                UIFont.boldSystemFont(ofSize: CellViewElementValues.sharedInstance.hintDefaultTextSize * 1.15 * CellViewElementValues.sharedInstance.scaleFactor!)
        }
            
        let hintTextAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: colorTheme.fonts,
            NSAttributedString.Key.font: CellViewElementValues.sharedInstance.hintFont!
        ]
        
        let hintText = NSAttributedString(string: hint!, attributes: hintTextAttributes)
        
        hintText.draw(at: CGPoint(x: CGFloat(4), y: CGFloat(2)))
    }
    
    private func addGuessText() {
        if guess == nil {
            // return if there is no guess to render
            return
        }
        
        // if the sharedInstance doesn't have the base font calculated
        if CellViewElementValues.sharedInstance.guessFont == nil {
            CellViewElementValues.sharedInstance.guessFont =
                UIFont(name: "Verdana", size: CellViewElementValues.sharedInstance.guessDefaultTextSize * CellViewElementValues.sharedInstance.scaleFactor!)
                ??
                UIFont.systemFont(ofSize: CellViewElementValues.sharedInstance.guessDefaultTextSize * CellViewElementValues.sharedInstance.scaleFactor!)
        }
        
        // base font
        var guessTextAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: colorTheme.fonts,
            NSAttributedString.Key.font: CellViewElementValues.sharedInstance.guessFont!
        ]
        
        if Defaults[\.highlightConflictingEntries] == true && hasGuessAllegiance(.conflict) {
            if CellViewElementValues.sharedInstance.guessConflictShadow == nil {
                // if the sharedInstance doesn't have the Conflict Shadow calculated
                let shadow = NSShadow()
                shadow.shadowColor = getGuessAllegianceColor(GuessAllegiance.conflict)
                shadow.shadowBlurRadius = 9.0
                shadow.shadowOffset = CGSize(width: 0, height: 0)
                
                CellViewElementValues.sharedInstance.guessConflictShadow = shadow
            }
            
            // apply the Conflict Shadow
            guessTextAttributes[NSAttributedString.Key.shadow] = CellViewElementValues.sharedInstance.guessConflictShadow!
        } else if Defaults[\.highlightSameGuessEntry] == true && hasGuessAllegiance(.equal) {
            if CellViewElementValues.sharedInstance.guessEqualShadow == nil {
                // if the sharedInstance doesn't have the Equal Shadow calculated
                let shadow = NSShadow()
                shadow.shadowColor = getGuessAllegianceColor(GuessAllegiance.equal)
                shadow.shadowBlurRadius = 9.0
                shadow.shadowOffset = CGSize(width: 0, height: 0)
                
                CellViewElementValues.sharedInstance.guessEqualShadow = shadow
            }
            
            // apply the Equal Shadow
            guessTextAttributes[NSAttributedString.Key.shadow] = CellViewElementValues.sharedInstance.guessEqualShadow!
        }
        
        
        let guessText = NSAttributedString(string: guess!, attributes: guessTextAttributes)
        
        // calculate position elements and store them if not currently set on the sharedInstance
        if CellViewElementValues.sharedInstance.guessTextSize == nil {
            CellViewElementValues.sharedInstance.guessTextSize = guessText.size()
        }
        
        if CellViewElementValues.sharedInstance.guessPositionX == nil {
            CellViewElementValues.sharedInstance.guessPositionX = bounds.midX - (CellViewElementValues.sharedInstance.guessTextSize!.width / 2)
        }
        
        if CellViewElementValues.sharedInstance.guessPositionY == nil {
            CellViewElementValues.sharedInstance.guessPositionY = bounds.maxY - CellViewElementValues.sharedInstance.guessTextSize!.height - 1
        }
        
        // draw the guess
        guessText.draw(at: CGPoint(x: CellViewElementValues.sharedInstance.guessPositionX!,
                                   y: CellViewElementValues.sharedInstance.guessPositionY!))
        
    }
    
    private func addNotesText() {
        if guess != nil || note == nil {
            // return if there is a guess or there is no note to render
            return
        }
        
        // if the font hasn't been pre-created yet, then do so and store onto the sharedInstance
        if CellViewElementValues.sharedInstance.noteFont == nil {
           CellViewElementValues.sharedInstance.noteFont =
            UIFont(name: "CourierNewPS-BoldMT", size: CellViewElementValues.sharedInstance.noteDefaultTextSize * (CellViewElementValues.sharedInstance.scaleFactor! / 1.45))
            ??
            UIFont.boldSystemFont(ofSize: CellViewElementValues.sharedInstance.noteDefaultTextSize * (CellViewElementValues.sharedInstance.scaleFactor! / 1.5))
        }
        
        let noteTextAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: colorTheme.possibleNote,
            NSAttributedString.Key.font: CellViewElementValues.sharedInstance.noteFont!
        ]
        
        let noteText = NSAttributedString(string: note!, attributes: noteTextAttributes)
        
        // calculate the x and y position by looking at how much space we need to render
        // store these values into the sharedInstance
        if CellViewElementValues.sharedInstance.noteTextSize == nil {
            CellViewElementValues.sharedInstance.noteTextSize = noteText.size()
        }
        
        if CellViewElementValues.sharedInstance.notePositionX == nil {
            CellViewElementValues.sharedInstance.notePositionX = bounds.midX - (CellViewElementValues.sharedInstance.noteTextSize!.width / 2)
        }
        
        if CellViewElementValues.sharedInstance.notePositionY == nil {
            CellViewElementValues.sharedInstance.notePositionY = bounds.maxY - CellViewElementValues.sharedInstance.noteTextSize!.height - 1.5
        }
        
        // draw the note
        noteText.draw(at: CGPoint(x: CellViewElementValues.sharedInstance.notePositionX!,
                                  y: CellViewElementValues.sharedInstance.notePositionY!))
    }
 
    private func addBorders() {
        self.layer.addBorder(edge: .top, color: getCellAllegianceColor(topBorder), thickness: topBorder.borderWeight)
        self.layer.addBorder(edge: .right, color: getCellAllegianceColor(rightBorder), thickness: rightBorder.borderWeight)
        self.layer.addBorder(edge: .bottom, color: getCellAllegianceColor(bottomBorder), thickness: bottomBorder.borderWeight)
        self.layer.addBorder(edge: .left, color: getCellAllegianceColor(leftBorder), thickness: leftBorder.borderWeight)
    }
    
    private func patchCorners() {
        let color = getCellAllegianceColor(CellAllegiance.foe)
        let edgeLength = CellAllegiance.foe.borderWeight
        
        if topLeftCornerPatch {
            self.layer.addCorner(corner: .topLeft, color: color, edgeLenth: edgeLength)
        }
        if topRightCornerPatch {
            self.layer.addCorner(corner: .topRight, color: color, edgeLenth: edgeLength)
        }
        if bottomRightCornerPatch {
            self.layer.addCorner(corner: .bottomRight, color: color, edgeLenth: edgeLength)
        }
        if bottomLeftCornerPatch {
            self.layer.addCorner(corner: .bottomLeft, color: color, edgeLenth: edgeLength)
        }
    }
}
