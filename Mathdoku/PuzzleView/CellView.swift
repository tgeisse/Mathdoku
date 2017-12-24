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

import UIKit

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
    private var guessAllegiance: UInt8 = 0 { didSet { if oldValue != guessAllegiance { setNeedsDisplay() } } }
    
    enum CellAllegiance {
        case friend
        case foe
        case other
        
        var borderWeight: CGFloat {
            switch self {
            case .friend: return 0.25
            case .foe: return 1.2
            case .other: return 2.6
            }
        }
        
        var borderColor: UIColor {
            switch self {
            case .friend: return .black
            case .foe: return .black
            case .other: return .black
            }
        }
    }
    
    enum GuessAllegiance: UInt8 {
        case equal = 0b000000001
        case conflict = 0b000000010
        
        var shadowColor: UIColor {
            switch self {
            case .equal: return .green
            case .conflict: return .red
            }
        }
    }
    
    private var scaleFactor: CGFloat {
        return bounds.maxX / 100
    }
    private let defaultTextSizeForHint: CGFloat = 23.0
    private let defaultTextSizeForGuess: CGFloat = 54.0
    private let defaultTextSizeForNotes: CGFloat = 36.0
    
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
        self.backgroundColor = UIColor.clear
        self.layer.sublayers?.removeAll()
        
        // Add the borders around the cell
        addBorders()
        
        // Add the hint text, if there is one
        addHintText()
        
        // Add the guess text, if there is one
        addGuessText()
        
        // Add the note text, if there is one
        addNotesText()
    }
    
    private func addHintText() {
        if hint != nil {
            let hintTextAttributes: [NSAttributedStringKey : Any] = [
                NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: defaultTextSizeForHint * scaleFactor)
            ]
            
            let hintText = NSAttributedString(string: hint!, attributes: hintTextAttributes)
            
            hintText.draw(at: CGPoint(x: CGFloat(4), y: CGFloat(2)))
        }
    }
    
    private func addGuessText() {
        if guess != nil {
            
            var guessTextAttributes: [NSAttributedStringKey : Any] = [
                NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: defaultTextSizeForGuess * scaleFactor)
            ]
            
            if Defaults[.highlightConflictingEntries] == true && hasGuessAllegiance(.conflict) {
                let shadow = NSShadow()
                shadow.shadowColor = GuessAllegiance.conflict.shadowColor
                shadow.shadowBlurRadius = 9.0
                shadow.shadowOffset = CGSize(width: 0, height: 0)
                
                guessTextAttributes[NSAttributedStringKey.shadow] = shadow
            } else if Defaults[.highlightSameGuessEntry] == true && hasGuessAllegiance(.equal) {
                let shadow = NSShadow()
                shadow.shadowColor = GuessAllegiance.equal.shadowColor
                shadow.shadowBlurRadius = 9.0
                shadow.shadowOffset = CGSize(width: 0, height: 0)
                
                guessTextAttributes[NSAttributedStringKey.shadow] = shadow
            }
            
            
            let guessText = NSAttributedString(string: guess!, attributes: guessTextAttributes)
            
            // calculate the x and y position by looking at how much space we need to render
            let guessPositionX: CGFloat = bounds.midX - (guessText.size().width / 2)
            let guessPositionY: CGFloat = bounds.maxY - guessText.size().height
            
            guessText.draw(at: CGPoint(x: guessPositionX, y: guessPositionY))
            
        }
    }
    
    private func addNotesText() {
        if guess == nil, note != nil {
            let noteTextAttributes: [NSAttributedStringKey : Any] = [
                NSAttributedStringKey.foregroundColor: UIColor.init(red:0.0, green: 0.60, blue: 0.0, alpha: 1.0),
                //NSFontAttributeName: UIFont.boldSystemFont(ofSize: defaultTextSizeForNotes * (scaleFactor / 1.5))
                //NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body).withSize(textSizeForNotes)
                NSAttributedStringKey.font: UIFont(name: "CourierNewPS-BoldMT", size: defaultTextSizeForNotes * (scaleFactor / 1.45)) ?? UIFont.boldSystemFont(ofSize: defaultTextSizeForNotes * (scaleFactor / 1.5))
            ]
            
            let noteText = NSAttributedString(string: note!, attributes: noteTextAttributes)
            
            // calculate the x and y position by looking at how much space we need to render
            let notePositionX: CGFloat = bounds.midX - (noteText.size().width / 2)
            let notePositionY: CGFloat = bounds.maxY - noteText.size().height - 2
            
            noteText.draw(at: CGPoint(x: notePositionX, y: notePositionY))
            
        }
    }
 
    private func addBorders() {
        self.layer.addBorder(edge: .top, color: topBorder.borderColor, thickness: topBorder.borderWeight)
        self.layer.addBorder(edge: .right, color: rightBorder.borderColor, thickness: rightBorder.borderWeight)
        self.layer.addBorder(edge: .bottom, color: bottomBorder.borderColor, thickness: bottomBorder.borderWeight)
        self.layer.addBorder(edge: .left, color: leftBorder.borderColor, thickness: leftBorder.borderWeight)
    }
}
