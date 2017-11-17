//
//  PuzzleViewController.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/29/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit
import RealmSwift

@IBDesignable
class PuzzleViewController: UIViewController, UINavigationBarDelegate {
    var puzzle: Puzzle!
    var puzzleLoader: PuzzleLoader!
    
    // MARK: - Realm properties
    private lazy var realm: Realm = { return try! Realm() }()
    private lazy var playerProgress: PlayerProgress = self.loadPlayerProgress()
    private lazy var puzzleProgress: PuzzleProgress = self.loadPuzzleProgress()
    
    private func loadPlayerProgress() -> PlayerProgress {
        return realm.objects(PlayerProgress.self).filter("puzzleSize == \(puzzle.size)")[0]
    }
    
    private func loadPuzzleProgress() -> PuzzleProgress {
        if playerProgress.puzzleProgress == nil {
            // if a puzzleProgress does not exist for this puzzle
            // then write a new one to the database
            do {
                let newPuzzleProgress = PuzzleProgress()
                try realm.write {
                    playerProgress.puzzleProgress = newPuzzleProgress
                }
                return newPuzzleProgress
            } catch (let error) {
                fatalError("Error creating a new puzzle progress:\n\(error)")
            }
        } else {
            return playerProgress.puzzleProgress!
        }
    }
    
    // MARK: - Tap Gesture Recognizers
    @IBOutlet weak var puzzleGridSuperview: UIStackView! {
        didSet {
            // add a tap gesture recognizer to the puzzle grid
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewTappedGesture(recognizer:)))
            tapRecognizer.numberOfTapsRequired = 1
            puzzleGridSuperview.addGestureRecognizer(tapRecognizer)
            
            let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewTappedGesture(recognizer:)))
            doubleTapRecognizer.numberOfTapsRequired = 2
            puzzleGridSuperview.addGestureRecognizer(doubleTapRecognizer)
        }
    }
    @IBOutlet var gridRowStacks: [GridRowView]!
    
    // MARK: - Interface Buttons that may need hiding
    @IBOutlet weak var userGuessButton9: UIButton! { didSet { userGuessButton9.isHidden = puzzle.size < 9 }}
    @IBOutlet weak var userGuessButton8: UIButton! { didSet { userGuessButton8.isHidden = puzzle.size < 8 }}
    @IBOutlet weak var userGuessButton7: UIButton! { didSet { userGuessButton7.isHidden = puzzle.size < 7 }}
    @IBOutlet weak var userGuessButton6: UIButton! { didSet { userGuessButton6.isHidden = puzzle.size < 6 }}
    @IBOutlet weak var userGuessButton5: UIButton! { didSet { userGuessButton5.isHidden = puzzle.size < 5 }}
    @IBOutlet weak var userGuessButton4: UIButton! { didSet { userGuessButton4.isHidden = puzzle.size < 4 }}
    
    // MARK: - Interface success screen outlets
    @IBOutlet weak var successOverlayView: UIView!
    
    // MARK: - Entry Mode Toggle Variables
    private enum EntryModes {
        case guessing
        case notePossible
        case noteImpossible
    }
    
    private var entryMode = EntryModes.guessing {
        didSet{
            // switching on new value - what we are transitioning to
            switch entryMode {
            case .guessing:
                // clear out the selected notes
                selectedNoteCells = []
                
                // rehighlight the guessing cells
                for cell in friendsToSelectedCell {
                    cell.currentHighlightState = .friendly
                }
                selectedCell?.currentHighlightState = .selected
            case .notePossible, .noteImpossible:
                // unhighlight the selected cell and its friendly cells
                for cell in friendsToSelectedCell {
                    cell.currentHighlightState = .unselected
                }
                selectedCell?.currentHighlightState = .unselected
                
                // if selectedNoteCells is empty, then append the current selected cell
                // only if it is not nil
                if let defaultCell = selectedCell, selectedNoteCells.count == 0 {
                    selectedNoteCells = [defaultCell]
                }
            }
        }
    }
    
    // MARK: - Guessing Mode Vars
    private var selectedCellPosition: CellPosition?
    private var selectedCell: CellContainerView? {
        didSet {
            // if the oldValue and the new value are the same, then the user clicked the same cell
            // don't do anything in that case. Otherwise, process the click
            if oldValue != selectedCell {
                // check to see if selectedCell is set and we can unwrap it
                if let cell = selectedCell {
                    // set the current cell to selected
                    cell.currentHighlightState = .selected
                    
                    // safely unwrap the position for the selected cell
                    if let cellPos = identifyCellPositionForCellContainerView(cell) {
                        // if I am already calculating it, then go ahead and save it
                        // Why use a calculated var on an expensive call?
                        selectedCellPosition = cellPos
                        
                        // get the cells in the same cage as the selected cell (aka "friendly")
                        friendsToSelectedCell = puzzle.getFriendliesForCell(cellPos).map {
                            return gridRowStacks[$0.row].rowCells[$0.col]
                        }
                        
                        // if my old value is not in the friendsToSelectedCells (new)
                        // then set the oldvalue to unselected
                        if let oldCell = oldValue, friendsToSelectedCell.contains(oldCell) == false {
                            oldCell.currentHighlightState = .unselected
                        }
                    }
                } else {
                    // in the case selectedCell is nil, then we are clearing the values
                    oldValue?.currentHighlightState = .unselected
                    friendsToSelectedCell = []
                    selectedCellPosition = nil
                }
            }
        }
    }
    
    private var friendsToSelectedCell = [CellContainerView]() {
        didSet {
            
            // values to be set to default color are oldValues that do not exist in the
            // new value set or are not equal to the current selectedCell
            for cell in oldValue.filter( { !friendsToSelectedCell.contains($0) && selectedCell != $0 } ) {
                cell.currentHighlightState = .unselected
            }
            
            // values to be set to the highlighted color are new values
            for cell in friendsToSelectedCell {
                cell.currentHighlightState = .friendly
            }
        }
    }
    
    // MARK: - Note Mode Vars
    private enum CellNotePossibility: Int {
        case possible   =  1
        case impossible = -1
        case none       =  0
    }
    
    private var selectedNoteCellsPositions: [CellPosition] {
        return selectedNoteCells.map { identifyCellPositionForCellContainerView($0)! }
    }
    
    private var selectedNoteCells = [CellContainerView]() {
        didSet {
            // if we have been set, then we need to go through and highlight cells appropriately
            
            // first, set cells that are no longer highlighted to the default cell color
            for cell in oldValue.filter( { !selectedNoteCells.contains($0) } ) {
                cell.currentHighlightState = .unselected
            }
            
            // next, highlight any new cells selected for note entry
            for cell in selectedNoteCells {
                cell.currentHighlightState = .possibleNote
            }
        }
    }
    
    private lazy var userCellNotePossibilities: [[[CellNotePossibility]]] = {
        let size = self.puzzle.size
        return Array(repeating:
                        Array(repeating:
                                Array(repeating: CellNotePossibility.none, count: self.puzzle.size)
                            , count: self.puzzle.size)
                    , count: self.puzzle.size)
    }()

    
    // MARK: - Gesture Recognizers      
    func viewTappedGesture(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            //DebugUtil.print("Number of taps required: \(recognizer.numberOfTapsRequired)")
            let view = recognizer.view
            let location = recognizer.location(in: view)
            let location2 = recognizer.location(ofTouch: 0, in: view)
            
            if let tappedSubview = view?.hitTest(location, with: nil) as? CellContainerView,
                let secondTappedSubview = view?.hitTest(location2, with: nil) as? CellContainerView {
                
                // if the tapgesture passed two us is a double tap AND the tapped subviews are the same
                if recognizer.numberOfTapsRequired == 2 && tappedSubview == secondTappedSubview {
                    toggleEntryMode()
                } else {
                    // else if the tapGesture was a single click OR a double click with 2 different tapped subviews
                    switch entryMode {
                    case .guessing:
                        selectedCell = tappedSubview
                    case .notePossible, .noteImpossible:
                        // determine which tapped subview to process
                        let processingSubview = (recognizer.numberOfTapsRequired == 2 ? secondTappedSubview : tappedSubview)
                        
                        // check to see if only a single cell can be selected at a time
                        if Defaults[.singleNoteCellSelection] {
                            // single note selection is enabled
                            selectedNoteCells = [processingSubview]
                        } else {
                            // multiple note selection is enabled
                            if let noteCellToRemove = selectedNoteCells.index(of: processingSubview) {
                                // if the tapped cell was already in the selectedNoteCells array
                                // then remove it
                                selectedNoteCells.remove(at: noteCellToRemove)
                            } else {
                                // otherwise append it
                                selectedNoteCells.append(processingSubview)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - UI Button Actions
    @IBAction func numberButtonPress(_ sender: UIButton) {
        if let buttonTitle = sender.currentTitle, let num = Int(buttonTitle) {
            switch entryMode {
            case .guessing:
                if let cellPosition = selectedCellPosition {
                    setGuessForCells(atPositions: [cellPosition], withAnswer: num)
                    
                    // if auto rotate is enabled, then rotate to the next free cell
                    if Defaults[.rotateAfterCellEntry] {
                        DebugUtil.print("auto rotation turned on -- rotating to next cell in friendly group")
                        if let nextCell = puzzle.getUnfilledFriendliesForCell(cellPosition).first {
                            selectedCell = gridRowStacks[nextCell.row].rowCells[nextCell.col]
                        }
                    }
                }
            case .notePossible, .noteImpossible:
                setNotesForCells(atPositions: selectedNoteCellsPositions, withNotes: [num])
            }
        }
    }
    
    @IBAction func eraseGuessOrNotes(_ sender: UIButton) {
        // TODO: evaluate whether or not pressing erase in note mode should also erase gueses
        switch entryMode {
        case .guessing:
            if let cellPosition = selectedCellPosition {
                if puzzle.cellIsGuessedAtPosition(cellPosition) {
                    // if the puzzle has a guess, erase it
                    setGuessForCells(atPositions: [cellPosition], withAnswer: nil)
                } else {
                    // if the puzzle does not have a guess, then erase its notes
                    setNotesForCells(atPositions: [cellPosition], withNotes: nil)
                }
            }
        case .notePossible, .noteImpossible:
            setNotesForCells(atPositions: selectedNoteCellsPositions, withNotes: nil)
        }
    }
    
    @IBAction func validatePuzzleEntries(_ sender: UIButton) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let guessedCellValidations = self?.puzzle.getGuessedCellPositionsWithGuessValidation() {
                // then animate the guess validation and re-enable gesture recognizers after the second animation
                for (guessedCellPosition, correctGuess) in guessedCellValidations {
                    
                    DispatchQueue.main.async {
                        if let cell = self?.gridRowStacks[guessedCellPosition.row].rowCells[guessedCellPosition.col] {
                            cell.currentValidationState = (correctGuess ? .valid : .invalid)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func randomReveal(_ sender: UIButton) {
        let unguessedCells = puzzle.getUnguessedCellPositionsWithAnswers()
        
        if unguessedCells.count > 0 {
            let randomCell = unguessedCells[Int(arc4random_uniform(UInt32(unguessedCells.count)))]
            
            entryMode = .guessing
            setGuessForCells(atPositions: [randomCell.cellPosition], withAnswer: randomCell.answer)
            selectedCell = gridRowStacks[randomCell.cellPosition.row].rowCells[randomCell.cellPosition.col]
        }
    }
    
    @IBAction func toggleNotes(_ sender: UIButton) {
        toggleEntryMode()
    }
    
    @IBAction func resetPuzzle(_ sender: UIButton) {
        alertUserYesNoMessage(title: "Reset Puzzle?", message: "Are you sure you want to erase all guesses and notes?", actionOnConfirm: resetCellNotesAndGuesses)
    }
    
    // MARK: - Puzzle progression UI buttons
    @IBAction func nextPuzzle(_ sender: UIButton) {
        // this can be used by either the success screen or the skiPuzzle button
        if sender.currentTitle == "Next Puzzle" {
            if PuzzleProducts.puzzleAllowance.allowance == 0 {
                let alert = self.alertOutOfPuzzlesAndCanPurchase(mentionWeeklyAllowance: PuzzleProducts.userIsWeekly, actionOnConfirm: segueToStore)
                self.showAlert(alert)
            } else {
                goToNextPuzle()
            }
        } else {
            // skip puzzle clicked us.
            // preload a puzzle if they can skip
            puzzleLoader.preloadPuzzleForSize(puzzle.size, withPuzzleId: playerProgress.activePuzzleId + 1)
            if PuzzleProducts.puzzleAllowance.allowance == 0 {
                // If the user is out of puzzles, tell them they have to buy (or wait for weekly)
                let alert = self.alertOutOfPuzzlesAndCanPurchase(mentionWeeklyAllowance: PuzzleProducts.userIsWeekly, messageOverride: "You cannot skip this puzzle until you have more to play.", actionOnConfirm: segueToStore)
                self.showAlert(alert)
            } else {
                // if the user has puzzles, then tell them that skipping will consume a puzzle and confirm first
                alertUserYesNoMessage(title: "Skip Puzzle?", message: "Are you sure you want to skip this puzzle? Skipping will use a puzzle allowance.", actionOnConfirm: skipPuzzle)
            }
        }
        
    }
    
    @IBAction func mainMenu(_ sender: UIButton) {
        // we are only using this on the success screen, so reset the notes before popping back
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Puzzle progression functions
    private func isPuzzleSuccessfullyFilled() {
        if puzzle.isSolved {
            // TODO: if you ever implement replay, then the incrementPuzzleId function will need to support a "to:" parameter
            incrementPlayerPuzzleProgress()
            setPuzzleProgress(to: false)
            puzzleLoader.preloadPuzzleForSize(puzzle.size, withPuzzleId: playerProgress.activePuzzleId)
            successOverlayView.isHidden = false
        }
    }
    
    private func skipPuzzle() {
        incrementPlayerPuzzleProgress()
        goToNextPuzle()
    }
    
    private func goToNextPuzle() {
        selectedCell = nil
        resetCellNotesAndGuesses()
        consumePuzzleAllowance()
        puzzle = puzzleLoader.loadNewPuzzleForSize(puzzle.size, withPuzzleId: playerProgress.activePuzzleId)
        writePuzzleToGrid()
        setPuzzleProgress(to: true)
        successOverlayView.isHidden = true
    }
    
    // MARK: - Private Helper Functions
    private func segueToStore() {
        DebugUtil.print("Seguing to the puzzle store from puzzle grid")
        performSegue(withIdentifier: "Puzzle Store Segue", sender: self)
    }
    
    private func identifyCellPositionForCellContainerView(_ cell: CellContainerView) -> CellPosition? {
        if let rowContainer = cell.superview as? GridRowView {
            let cellCol = rowContainer.subviews.index(of: cell)!
            let cellRow = gridRowStacks.index(of: rowContainer)!
            
            return CellPosition(row: cellRow, col: cellCol, puzzleSize: puzzle.size)
        } else {
            return nil
        }
    }
    
    private func setGuessForCells(atPositions: [CellPosition], withAnswer: Int?, withIdentifier: String = #function) {
        for atPosition in atPositions {
            gridRowStacks[atPosition.row].rowCells[atPosition.col].cell.guess = (withAnswer == nil ? nil : "\(withAnswer!)")
            puzzle.setGuessForCellPosition(atPosition, guess: withAnswer)
        }
        
        // if viewDidLoad called us, then we are loading the saved puzzle from Realm
        // this means we do not want to re-write anything to the realm, so skip
        if withIdentifier.contains("viewDidLoad") != true {
            DebugUtil.print("Entering Guess Save. Check the identifier: \(withIdentifier)")
            asyncWriteGuessForCells(atPositions: atPositions, withAnswer: withAnswer)
        }
        
        // check to see if this entry solved the puzzle
        isPuzzleSuccessfullyFilled()
    }
    
    private func setNotesForCells(atPositions: [CellPosition], withNotes notes: [Int]?, overridePossibilty: [CellNotePossibility]? = nil, withIdentifier: String = #function) {
        // (1) make the changes in memory
        for cell in atPositions {
            if let notes = notes {
                // if the note is not nil, then update the notes for the passed in cells
                for (arrayIndex, note) in notes.enumerated() {
                    let noteIndex = note - 1
                    
                    // we will allow an override if one was passed. But first, check to make sure the count lines up
                    // override is currently only used when loaded from viewDidLoad
                    if let possibleOverride = overridePossibilty, possibleOverride.count == notes.count {
                        userCellNotePossibilities[cell.row][cell.col][noteIndex] = possibleOverride[arrayIndex]
                    } else {
                        let currentNotePossibility = userCellNotePossibilities[cell.row][cell.col][noteIndex]
                        let notePossibilityMode = (entryMode == .noteImpossible ? CellNotePossibility.impossible : .possible)
                        
                        userCellNotePossibilities[cell.row][cell.col][noteIndex] = (currentNotePossibility == notePossibilityMode ? .none : notePossibilityMode)
                    }
                }
            } else {
                // if the note is nil, then we are setting everything to nothing again
                // quickest way to do this is to set a new array
                userCellNotePossibilities[cell.row][cell.col] = Array(repeating: CellNotePossibility.none, count: puzzle.size)
            }
            
            // (2) while still looping, update the user interface with the new values
            // since we know we made a change to the cell, then we don't have to check old values
// TODO: This currently only supports possible notes. Update to support impossible notes
// more accurately speaking: any note, possible or impossible, gets marked as green
            let numberToSplitAt = (puzzle.size >= 6 ? Int((Double(puzzle.size) / 2.0).rounded(.up)) : -1)
            let noteString = userCellNotePossibilities[cell.row][cell.col].enumerated().reduce("") {
                $0 + ($1.element == .none ? " " : "\($1.offset + 1)") + ($1.offset + 1 == numberToSplitAt ? "\n" : "")
            }
            
            gridRowStacks[cell.row].rowCells[cell.col].cell.note = noteString
        }
        
        // (3) initiate an async save of the notes - we don't want to hold the user up while Realm catches up
        // If we are being called from viewDidLoad, then we are loading from Realm - no need to initiate a save
        if withIdentifier.contains("viewDidLoad") != true {
            DebugUtil.print("Entering Cell Note Save. Check the identifier: \(withIdentifier)")
            asyncWriteNotesForCells(atPositions: atPositions)
            //asyncWriteCellNotes(userCellNotePossibilities)
        }
    }

    private func toggleEntryMode() {
        entryMode = (entryMode == .guessing ? .notePossible : .guessing)
    }
    
    private func alertUserYesNoMessage(title: String, message: String, actionOnConfirm: @escaping () -> ()) {
        let alert = self.alertWithTwoButtons(title: title, message: message,
                                             cancelButtonTitle: "No",
                                             successButtonTitle: "Yes",
                                             actionOnConfirm: actionOnConfirm)
        self.showAlert(alert)
    }
    
    // MARK: - Realm helper functions
    private func asyncWriteNotesForCells(atPositions: [CellPosition]) {
        let puzzleSize = puzzle.size
        // (1) get a dictionary mapping of the notes we need to save with their respective positions
        var notesToSave = Dictionary<CellPosition, [CellNotePossibility]>()
        
        for cell in atPositions {
            notesToSave[cell] = userCellNotePossibilities[cell.row][cell.col]
        }
        
        // (2) dispatch onto another queue
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let realm = try Realm()
                
                // (3) get the existing puzzle note items in the realm database to be updated
                // we should already have a playerProgress if we make it this far, we just may not have any puzzleNotes if this is a first run
                if let puzzleNotes = realm.objects(PlayerProgress.self).filter("puzzleSize == \(puzzleSize)").first?.puzzleProgress?.puzzleNotes {
                    // (4) open a realm writing block
                    try realm.write {
                        // (5) loop through the cells passed to us
                        for savingNote in notesToSave {
                            let cell = savingNote.key // the key is the cell position of the note
                            let possibilities = savingNote.value // the possibilities are the breakdown of notes in the cell
                            
                            // (6) check to see if a PuzzleNote exists for this cell
                            let puzzleNoteQuery = puzzleNotes.filter("cellId == \(cell.cellId)")
                            let puzzleNoteForCell: PuzzleNote
                            
                            if puzzleNoteQuery.count == 0 {
                                // (7) if a PuzzleNote does not exist for this cell, then create one
                                puzzleNoteForCell = PuzzleNote()
                                puzzleNoteForCell.cellId = cell.cellId
                                puzzleNotes.append(puzzleNoteForCell)
                                
                            } else {
                                // (7b) otherwise, get the first element in the query - this is our puzzleNote for the cell
                                puzzleNoteForCell = puzzleNoteQuery.first!
                            }
                            
                            // (8) now that we have our puzzleNote, let's add the CellNote Possibilities to it
                            for (index, possibility) in possibilities.enumerated() {
                                let possibilityIndex = index + 1
                                let cellNoteQuery = puzzleNoteForCell.notes.filter("note == \(possibilityIndex)")
                                let puzzleCellNote: PuzzleCellNote
                                
                                if cellNoteQuery.count == 0 {
                                    // (9) if we do not yet have a PuzzleCellNote for this note, then add it
                                    puzzleCellNote = PuzzleCellNote()
                                    puzzleCellNote.note = possibilityIndex
                                    puzzleNoteForCell.notes.append(puzzleCellNote)
                                } else {
                                    // (9b) or, if we have one, then get the first element in the query - this is our CellNote for this note
                                    puzzleCellNote = cellNoteQuery.first!
                                }
                                
                                // (10) change the cell note possibility. It's an int, so:
                                //                  -1: impossible
                                //                   0: none
                                //                   1: possible
                                //puzzleCellNote.possibility = (possibility == .impossible ? -1 : (possibility == .possible ? 1 : 0))
                                puzzleCellNote.possibility = possibility.rawValue
                            }
                        }
                    }
                }
                
            } catch (let error) {
                fatalError("Error trying to async save the cell notes: \(error)")
            }
        }
    }
    
    private func asyncWriteGuessForCells(atPositions: [CellPosition], withAnswer: Int?) {
        let puzzleSize = puzzle.size
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let realm = try Realm()
                if let puzzleGuesses = realm.objects(PlayerProgress.self).filter("puzzleSize == \(puzzleSize)").first?.puzzleProgress?.puzzleGuesses {
                    
                    try realm.write {
                        for cell in atPositions {
                            let puzzleGuessQuery = puzzleGuesses.filter("cellId == \(cell.cellId)")
                            let puzzleGuessForCell: PuzzleGuess
                            
                            if puzzleGuessQuery.count == 0 {
                                // if we were not able to find a guess query matching the cellId
                                // then create a new one for use
                                puzzleGuessForCell = PuzzleGuess()
                                puzzleGuessForCell.cellId = cell.cellId
                                puzzleGuesses.append(puzzleGuessForCell)
                            } else {
                                // otherwise, the first result is the puzzle guess we will be changing the value
                                puzzleGuessForCell = puzzleGuessQuery.first!
                            }
                            
                            puzzleGuessForCell.guess.value = withAnswer
                        }
                    }
                }
            } catch (let error) {
                fatalError("Error trying to save guess for cell:\n\(error)")
            }
        }
    }
    
    private func incrementPlayerPuzzleProgress() {
        playerProgress.incrementPuzzleId(withRealm: realm)
    }
    
    private func setPuzzleProgress(to: Bool) {
        puzzleProgress.setInProgress(to: to, withRealm: realm)
    }

    // MARK: - Puzzle Setup Functions
    private func consumePuzzleAllowance() {
        DebugUtil.print("Consuming a puzzle allowance")
        if let allowance = realm.objects(Allowances.self).filter("allowanceId = '\(AllowanceTypes.puzzle.id())'").first {
            allowance.decrementAllowance(by: 1, withRealm: realm)
        }
    }
    
    private func resetCellNotesAndGuesses() {
        // (1) build an array of CellPositions that matches the size of the puzzle
        var cellPositions = [CellPosition]()
        
        for cellId in 0..<(puzzle.size * puzzle.size) {
            cellPositions.append(CellPosition(cellId: cellId, puzzleSize: puzzle.size))
        }
        
        // (2) use said array to set all of the values for notes and guesses to nil
        setGuessForCells(atPositions: cellPositions, withAnswer: nil)
        setNotesForCells(atPositions: cellPositions, withNotes: nil)
    }
    
    private func writePuzzleToGrid() {
        // set cage boundaries - loop until the puzzle size squared
        for cell in 0..<(puzzle.size * puzzle.size) {
            // set the x,y coordinates for when we need to set the view
            // let cellPosition: (row: Int, col: Int) = (cell / puzzle.size, cell % puzzle.size)
            let cellPosition = CellPosition(cellId: cell, puzzleSize: puzzle.size)
            
            if let cellNeighborAllegience = puzzle.neighborsInSameCageForCell(cellPosition) {
                let cellView = gridRowStacks[cellPosition.row].rowCells[cellPosition.col].cell
                
                // empty out the hintText
                cellView.hint = nil
                
                // if we were able to get a cellView and its allegiences, then set the borders
                
                cellView.topBorder = (cellPosition.row == 0 ? .other : (cellNeighborAllegience.north ? .friend : .foe))
                
                cellView.rightBorder = (cellPosition.col == puzzle.size - 1 ? .other : (cellNeighborAllegience.east ? .friend : .foe))
                
                cellView.bottomBorder = (cellPosition.row == puzzle.size - 1 ? .other : (cellNeighborAllegience.south ? .friend : .foe))
                
                cellView.leftBorder = (cellPosition.col == 0 ? .other : (cellNeighborAllegience.west ? .friend : .foe))
            }
        }
        
        for key in puzzle.cages.keys {
            if let cage = puzzle.cages[key] {
                let cell: (row: Int, col: Int) = (cage.firstCell / puzzle.size, cage.firstCell % puzzle.size)
                gridRowStacks[cell.row].rowCells[cell.col].cell.hint = puzzle.cages[key]?.hintText ?? "#ERR#"
            }
            
        }
    }
    
    private func hideUnneededRowsAndCells() {
        gridRowStacks[0..<puzzle.size].forEach{ $0.subviews[puzzle.size..<9].forEach{ $0.isHidden = true } }
        gridRowStacks[puzzle.size..<9].forEach{ $0.isHidden = true }ç
    }
    
    // MARK: - View Lifecycle
    var loadingStart: Date?
    var loadingEnded: Date? {
        didSet {
            if let start = loadingStart, let end = loadingEnded {
                DebugUtil.print("Difference between loading times: \(end.timeIntervalSince(start))")
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DebugUtil.print("viewDidAppear")
        loadingEnded = Date()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DebugUtil.print("viewWillAppear")
        loadingEnded = Date()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        hideUnneededRowsAndCells()
        writePuzzleToGrid()
        
        // check to see if the puzzle is in progress - it is the only way we'd have something to load
        if puzzleProgress.inProgress == true {
            // will want to write the saved state to the grid here
            for savedGuess in puzzleProgress.puzzleGuesses.filter("guess != nil") {
                let cellPos = CellPosition(cellId: savedGuess.cellId, puzzleSize: puzzle.size)
                setGuessForCells(atPositions: [cellPos], withAnswer: savedGuess.guess.value)
            }
            
            for savedNote in puzzleProgress.puzzleNotes {
                let cellPos = CellPosition(cellId: savedNote.cellId, puzzleSize: puzzle.size)
                let notesForCellIndex = puzzleProgress.puzzleNotes.index(of: savedNote)!
                let nonBlankNotesForCell = puzzleProgress.puzzleNotes[notesForCellIndex].notes.filter("possibility != 0")
                
                if nonBlankNotesForCell.count > 0 {
                    var noteInts = [Int]()
                    var notePossibility = [CellNotePossibility]()
                    
                    nonBlankNotesForCell.forEach {
                        noteInts.append($0.note)
                        notePossibility.append( CellNotePossibility(rawValue: $0.possibility) ?? .none )
                    }
                    
                    setNotesForCells(atPositions: [cellPos], withNotes: noteInts, overridePossibilty: notePossibility)
                }
            }
        } else {
            // the puzzle is not in progress, so reset the guess and notes
            // TODO: we will eventually want to add some logic to this else statement so that it does not always execute
            resetCellNotesAndGuesses()
            
            // set the puzzle to in progress
            setPuzzleProgress(to: true)
            
            // since this is a new puzzle, then we will need to consume a puzzle allowance
            consumePuzzleAllowance()
        }
        
        DebugUtil.print("viewDidLoad")
        loadingEnded = Date()
    }
    override func loadView() {
        super.loadView()
        loadingStart = Date()
    }
}
