//
//  PuzzleViewController.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/29/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds
import SwiftyUserDefaults

@IBDesignable
class PuzzleViewController: UIViewController, UINavigationBarDelegate {
    // MARK: - View Controller properties
    var puzzle: Puzzle!
    private var nextPuzzleId: Int? = nil
    private var observerTokens: [NSObjectProtocol] = []
    
    // MARK: - References to View Items
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var successOverlayView: UIView!
    @IBOutlet weak var successOverlayBackgroundView: UIView!
    @IBOutlet weak var bestTimeTitle: UILabel! {
        didSet {
            // update the best time title label for the puzzle size
            bestTimeTitle.text = "Best Size \(puzzle.size) Time"
        }
    }
    @IBOutlet weak var bestTimeLabel: UILabel!
    @IBOutlet weak var yourTimeTitle: UILabel!
    @IBOutlet weak var finalTimeLabel: UILabel!
    @IBOutlet weak var puzzleCompleteLabel: UILabel! { didSet { puzzleCompleteLabel.textColor = ColorTheme.sharedInstance.puzzleCompleteAndCountdown } }
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var bannerViewHeight: NSLayoutConstraint!
    
    private var gridRowStacks: [GridRowView] {
        guard let returnValue = puzzleGridSuperview.subviews as? [GridRowView] else {
            CrashWrapper.notifyException(name: .cast, reason: "A view that is not a Grid Row View made it into the puzzle grid.")
            fatalError("A view that is not a Grid Row View made it into the puzzle grid.")
        }
        
        return returnValue
    }
    @IBOutlet weak var gameTimerBackground: GameTimerBackgroundView!
    @IBOutlet weak var gameTimerLabel: UILabel!
    
    
    // MARK: - Game state properties
    private enum GameState {
        case loading
        case playing
        case paused
        case finished
    }
    private var gameState = GameState.loading {
        didSet {
            DebugUtil.print("Game State: \(oldValue) -> \(gameState)")
            
            if [GameState.finished, .playing].contains(gameState) {
                setNextPuzzleId()
            }
        }
    }
    
    // MARK: - Game timer properties
    private var timer = GameTimer()
    private let countdownTag = 554455
    private var gameTimer = 0.0 {
        didSet {
            gameTimerLabel.text = createTimeString(from: gameTimer)
        }
    }
    
    private enum TimerState {
        case stopped
        case start
        case running
        case pause
        case final
        case reset
    }
    private var timerState: TimerState = .stopped {
        didSet {
            DebugUtil.print("Timer State: \(oldValue) -> \(timerState)")
            
            switch timerState {
            case .stopped:
                break
            case .start:
                startTimer()
            case .running:
                break
            case .pause:
                pauseTimer()
            case .final:
                pauseTimer()
                saveFinalTimer()
            case .reset:
                resetTimer()
            }
        }
    }
    
    // MARK: - Game move history
    private let moveHistory = MoveHistory()
    
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
            } catch let error {
                error.report()
                fatalError("Error creating a new puzzle progress:\n\(error)")
            }
        } else {
            return playerProgress.puzzleProgress!
        }
    }
    
    // MARK: - Tap Gesture Recognizer Registration
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
    
    // MARK: - Interface Buttons that may need hiding
    @IBOutlet weak var userGuessButton9: UIButton! { didSet { userGuessButton9.isHidden = puzzle.size < 9 }}
    @IBOutlet weak var userGuessButton8: UIButton! { didSet { userGuessButton8.isHidden = puzzle.size < 8 }}
    @IBOutlet weak var userGuessButton7: UIButton! { didSet { userGuessButton7.isHidden = puzzle.size < 7 }}
    @IBOutlet weak var userGuessButton6: UIButton! { didSet { userGuessButton6.isHidden = puzzle.size < 6 }}
    @IBOutlet weak var userGuessButton5: UIButton! { didSet { userGuessButton5.isHidden = puzzle.size < 5 }}
    @IBOutlet weak var userGuessButton4: UIButton! { didSet { userGuessButton4.isHidden = puzzle.size < 4 }}
    
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
                
                // highlight cells
                highlightGuesses(for: .equal)
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
                
                // unhighlight equal mode
                highlightGuesses(for: .equal, unhighlight: true)
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
                
                highlightGuesses(for: .equal)
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
    @objc func viewTappedGesture(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            //DebugUtil.print("Number of taps required: \(recognizer.numberOfTapsRequired)")
            let view = recognizer.view
            let location = recognizer.location(in: view)
            let location2 = recognizer.location(ofTouch: 0, in: view)
            
            if let tappedSubview = view?.hitTest(location, with: nil) as? CellContainerView,
                let secondTappedSubview = view?.hitTest(location2, with: nil) as? CellContainerView {
                
                // if the tapgesture passed two us is a double tap AND the tapped subviews are the same
                if recognizer.numberOfTapsRequired == 2 && tappedSubview == secondTappedSubview {
                    if Defaults[\.doubleTapToggleNoteMode] {
                        toggleEntryMode()
                    }
                } else {
                    // else if the tapGesture was a single click OR a double click with 2 different tapped subviews
                    switch entryMode {
                    case .guessing:
                        selectedCell = tappedSubview
                    case .notePossible, .noteImpossible:
                        // determine which tapped subview to process
                        let processingSubview = (recognizer.numberOfTapsRequired == 2 ? secondTappedSubview : tappedSubview)
                        
                        // check to see if only a single cell can be selected at a time
                        if Defaults[\.singleNoteCellSelection] {
                            // single note selection is enabled
                            selectedNoteCells = [processingSubview]
                        } else {
                            // multiple note selection is enabled
                            if let noteCellToRemove = selectedNoteCells.firstIndex(of: processingSubview) {
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
                    if Defaults[\.rotateAfterCellEntry] {
                        DebugUtil.print("auto rotation turned on -- rotating to next cell in friendly group")
                        let unfilledFriendlies = puzzle.getUnfilledFriendliesForCell(cellPosition)
                        
                        if let nextCell = unfilledFriendlies.filter( { $0.cellId > cellPosition.cellId } ).first ?? unfilledFriendlies.first {
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
        // log an event to capture usage of this feature
        AnalyticsWrapper.logEvent(.selectContent, contentType: .featureUsage, id: "id-puzzleValidation")
        
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
        if gameState == .playing {
            let unguessedCells = puzzle.getUnguessedCellPositionsWithAnswers()
            
            if unguessedCells.count > 0 {
                let randomCell = unguessedCells[Int(arc4random_uniform(UInt32(unguessedCells.count)))]
                
                entryMode = .guessing
                setGuessForCells(atPositions: [randomCell.cellPosition], withAnswer: randomCell.answer)
                selectedCell = gridRowStacks[randomCell.cellPosition.row].rowCells[randomCell.cellPosition.col]
            }
            
            // log an event to capture usage of this feature
            AnalyticsWrapper.logEvent(.selectContent, contentType: .featureUsage, id: "id-randomGuessReveal")
        }
    }
    
    @IBAction func toggleNotes(_ sender: UIButton) {
        toggleEntryMode()
    }
    
    @IBAction func resetPuzzle(_ sender: UIButton) {
        alertUserYesNoMessage(title: "Reset Puzzle?", message: "Are you sure you want to erase all guesses and notes?", actionOnConfirm: { [weak self] in
            self?.timerState = .reset
            self?.gameState = .loading
            self?.resetCellNotesAndGuesses()
            self?.fillInUnitCells()
            self?.startCountdownTimer()
        })
    }
    
    @IBAction func undoMove(_ sender: UIButton) {
        if let moves = moveHistory.undo() {
            AnalyticsWrapper.logEvent(.selectContent, contentType: .featureUsage, id: "id-undoMove")
            processMoveHistory(forMoves: moves, moveDirection: .undo)
        }
    }
    
    @IBAction func redoMove(_ sender: UIButton) {
        if let moves = moveHistory.redo() {
            AnalyticsWrapper.logEvent(.selectContent, contentType: .featureUsage, id: "id-redoMove")
            processMoveHistory(forMoves: moves, moveDirection: .redo)
        }
    }
    
    // MARK: - Puzzle progression UI buttons
    @IBAction func nextPuzzle(_ sender: UIButton) {
        // this can be used by either the success screen or the skiPuzzle button
        DebugUtil.print("Entering nextPuzzle")
        if sender.currentTitle == "Next Puzzle" {
            // analytics - going to next puzzle
            DebugUtil.print("Puzzle was completed")
            AnalyticsWrapper.logEvent(.selectContent, contentType: .puzzlePlayed, id: "id-nextPuzzle")
            
            if PuzzleProducts.puzzleAllowance.allowance == 0 {
                let alert = self.alertOutOfPuzzlesAndCanPurchase(mentionRefreshPeriod: PuzzleProducts.userIsFree, actionOnConfirm: segueToStore)
                self.showAlert(alert)
            } else {
                goToNextPuzzle()
            }
        } else {
            // analytics - puzzle is trying to be skipped
            DebugUtil.print("Request to skip")
            AnalyticsWrapper.logEvent(.selectContent, contentType: .featureUsage, id: "id-skipPuzzle", name: "puzzleSkipRequest")
            
            // skip puzzle clicked us.
            if PuzzleProducts.puzzleAllowance.allowance == 0 {
                // If the user is out of puzzles, tell them they have to buy (or wait for daily)
                DebugUtil.print("Out of puzzles for skip - prompting the user")
                let alert = self.alertOutOfPuzzlesAndCanPurchase(mentionRefreshPeriod: PuzzleProducts.userIsFree, messageOverride: "You cannot skip this puzzle until you have more to play.", actionOnConfirm: segueToStore)
                DebugUtil.print("Successfully created alert for skip, out of puzzles")
                self.showAlert(alert)
                DebugUtil.print("Successfully displayed alert for skip, out of puzzles")
            } else {
                // if the user has puzzles, then tell them that skipping will consume a puzzle and confirm first
                setNextPuzzleId() // also set the next puzzle ID (preloads it, too)
                DebugUtil.print("Puzzles available for skip - prompting the user")
                alertUserYesNoMessage(title: "Skip Puzzle?", message: "Are you sure you want to skip this puzzle? Skipping will use a puzzle allowance.", actionOnConfirm: skipPuzzle)
            }
        }
        
    }
    
    @IBAction func mainMenu(_ sender: UIButton) {
        // we are only using this on the success screen, so reset the notes before popping back
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Puzzle progression functions
    private func checkPuzzleIsSolved() {
        if puzzle.isSolved {
            // TODO: if you ever implement replay, then the incrementPuzzleId function will need to support a "to:" parameter
            timerState = .final
            gameState = .finished
            updateShowSuccessView()
            incrementPlayerPuzzleProgress()
            setPuzzleProgress(to: false)
            
            // analytics - puzzle was successfully completed
            AnalyticsWrapper.logEvent(.selectContent, contentType: .puzzlePlayed, id: "id-puzzleCompleted", name: "puzzleSuccessfullyFilled")
        }
    }
    
    private func setNextPuzzleId(force: Bool = false) {
        if nextPuzzleId == nil || force {
            nextPuzzleId = PuzzleLoader.sharedInstance.getNextPuzzleId(forSize: puzzle.size)
            PuzzleLoader.sharedInstance.preloadPuzzle(forSize: puzzle.size, withPuzzleId: nextPuzzleId!)
        }
    }
    
    private func updateShowSuccessView() {
        if let bestTime = playerProgress.puzzlesSolved.filter("timeToSolve != nil").sorted(byKeyPath: "timeToSolve", ascending: true).first,
            bestTime.puzzleId != playerProgress.activePuzzleId {
            // previous best time
            bestTimeLabel.text = createTimeString(from: bestTime.timeToSolve.value ?? 0.0)
            bestTimeLabel.textColor = ColorTheme.sharedInstance.fonts
        } else {
            // new best time
            bestTimeLabel.text = "New Best Time!"
            bestTimeLabel.textColor = ColorTheme.sharedInstance.positiveTextLabel
        }
        
        finalTimeLabel.text = gameTimerLabel.text
        successOverlayView.isHidden = false
    }
    
    private func skipPuzzle() {
        // track that the puzzle has been skipped
        AnalyticsWrapper.logEvent(.selectContent, contentType: .featureUsage, id: "id-skipPuzzle", name: "puzzleSkipped")
        
        gameState = .loading
        removeCountdownTimer()
        incrementPlayerPuzzleProgress()
        goToNextPuzzle()
    }
    
    private func goToNextPuzzle() {
        gameState = .loading
        selectedCell = nil
        timerState = .reset
        resetCellNotesAndGuesses()
        consumePuzzleAllowance()
        puzzle = PuzzleLoader.sharedInstance.fetchPuzzle(forSize: puzzle.size, withPuzzleId: playerProgress.activePuzzleId)
        writePuzzleToGrid()
        fillInUnitCells()
        setPuzzleProgress(to: true)
        successOverlayView.isHidden = true
        
        AnalyticsWrapper.logEvent(.selectContent, contentType: .puzzlePlayed, id: "id-startNextPuzzle", name: "goToNextPuzzle")
        
        startCountdownTimer()
    }
    
    // MARK: - User Assisting Functions
    private func fillInUnitCells() {
        if Defaults[\.fillInGiveMes] && !puzzle.isSolved {
            DebugUtil.print("filling in give me / unit cells")
            puzzle.getUnitCellsWithAnswers().forEach {
                setGuessForCells(atPositions: [$0.cell], withAnswer: $0.answer, mutatesMoveHistory: false)
            }
        }
    }
    
    private func removePossibleNotesAfterGuess(_ guess: Int, atCell cell: CellPosition) -> [Move] {
        var moves = [Move]()
        
        if Defaults[\.clearNotesAfterGuessEntry] {
            let guessIndex = guess - 1
            var cellsToRemoveNoteForGuess: Set<CellPosition> = []
            
            // loop through the size of the puzzle
            for i in 0..<puzzle.size {
                if userCellNotePossibilities[cell.row][i][guessIndex] == .possible {
                    let cell = CellPosition(row: cell.row, col: i, puzzleSize: puzzle.size)
                    cellsToRemoveNoteForGuess.insert(cell)
                    moves.append((cell, .note(number: guess, fromPossibility: CellNotePossibility.possible.rawValue, toPossibility: CellNotePossibility.none.rawValue)))
                }
                
                if userCellNotePossibilities[i][cell.col][guessIndex] == .possible {
                    let cell = CellPosition(row: i, col: cell.col, puzzleSize: puzzle.size)
                    cellsToRemoveNoteForGuess.insert(cell)
                    moves.append((cell, .note(number: guess, fromPossibility: CellNotePossibility.possible.rawValue, toPossibility: CellNotePossibility.none.rawValue)))
                }
            }
            
            setNotesForCells(atPositions: Array(cellsToRemoveNoteForGuess), withNotes: [guess], mutatesMoveHistory: false)
        }
        
        return moves
    }
    
    private func highlightGuesses(for allegiances: [CellView.GuessAllegiance], unhighlight: Bool = false) {
        allegiances.forEach {
            highlightGuesses(for: $0, unhighlight: unhighlight)
        }
    }

    private let highlightSameQueue = DispatchQueue(label: "\(AppSecrets.domainRoot).highlightSame", qos: .userInitiated)
    private let highlightConflictQueue = DispatchQueue(label: "\(AppSecrets.domainRoot).highlightConflict", qos: .userInitiated)
    private let highlightRequests = HighlightRequestQueue()
    private func highlightGuesses(for allegiance: CellView.GuessAllegiance, unhighlight: Bool = false) {
        let queue: DispatchQueue
        let queueName: String
        let identifyCellsNeedingAllegiance: () -> [CellPosition]
        
        DebugUtil.print("a. request to highlight guesses. Setting necessary default vars")
        switch allegiance {
        case .equal:
            queue = highlightSameQueue
            queueName = "highlightSame"
            identifyCellsNeedingAllegiance = { [weak self] in
                if let selectedCell = self?.selectedCellPosition,
                    let cellsWithSameGuess = self?.puzzle.identifyCellsWithSameGuessAsCell(selectedCell) {
                    return cellsWithSameGuess
                } else {
                    return []
                }
            }
            
        case .conflict:
            queue = highlightConflictQueue
            queueName = "highlightConflict"
            identifyCellsNeedingAllegiance = { [weak self] in
                if let conflictingCells = self?.puzzle.identifyConflictingGuesses() {
                    return conflictingCells
                } else {
                    return []
                }
            }
        }
        
        highlightRequests.addRequest(for: allegiance)
        queue.async { [weak self] in
            // (1) see how many outstanding requests to highlight this type of allegiance
            let outstandingRequests = self?.highlightRequests.numberRequests(for: allegiance) ?? 0
            DebugUtil.print("1. entered into queue \(queueName). There are \(outstandingRequests) outstanding requests to process")
            
            if outstandingRequests > 0 {
                // (2) identify cells needing the allegiance flag set
                DebugUtil.print("2. identifying cells needing allegiance flag set")
                let cellsNeedingAllegiance = identifyCellsNeedingAllegiance()
                
                // (3) dispatch back to the main queue, remove old highlights, and add new highlights
                DebugUtil.print("3. dispatch back to main queue to handle highlight flag changes")
                DispatchQueue.main.async {
                    // remove the flag from any cells currently holding it
                    DebugUtil.print("b. remove guess allegiance \(queueName) from cells currently holding it")
                    self?.gridRowStacks.forEach {
                        $0.rowCells.forEach {
                            if $0.cell.hasGuessAllegiance(allegiance) {
                                $0.cell.removeGuessAllegiance(allegiance)
                            }
                        }
                    }
                    DebugUtil.print("c. done removing guess allegiance \(queueName) from cells")
                    
                    // next, add the flag to cells needing it if there are any that need the highlighting
                    DebugUtil.print("d. identified \(cellsNeedingAllegiance.count) cell\(cellsNeedingAllegiance.count == 1 ? "" : "s") needing allegiance flag set")
                    if cellsNeedingAllegiance.count > 0 && !unhighlight {
                            DebugUtil.print("e. on main queue to add cell allegiance flag \(queueName)")
                            cellsNeedingAllegiance.forEach {
                                self?.gridRowStacks[$0.row].rowCells[$0.col].cell.addGuessAllegiance(allegiance)
                            }
                            DebugUtil.print("f. finished adding allegiance flag \(queueName)")
                    }
                }
                
                // (4) clearing the request queue for the allegiance
                self?.highlightRequests.clearRequests(for: allegiance)
                DebugUtil.print("4. cleared requests queue for allegiance \(queueName)")
            }
        }
    }
    
    // MARK: - Update cell values
    private func setGuessForCells(atPositions: [CellPosition], withAnswer: Int?, mutatesMoveHistory: Bool = true, withIdentifier: String = #function) {
        var moves = [Move]()
        
        for atPosition in atPositions {
            let curGuess = puzzle.getCurrentGuess(forCell: atPosition)
            if curGuess != withAnswer {
                moves.append((atPosition, .guess(from: curGuess, to: withAnswer)))
            }
            
            gridRowStacks[atPosition.row].rowCells[atPosition.col].cell.guess = (withAnswer == nil ? nil : "\(withAnswer!)")
            puzzle.setGuessForCellPosition(atPosition, guess: withAnswer)
        }
        
        // if viewDidLoad called us, then we are loading the saved puzzle from Realm
        // this means we do not want to re-write anything to the realm, so skip
        if withIdentifier.contains("viewDidLoad") != true {
            DebugUtil.print("Entering Guess Save. Check the identifier: \(withIdentifier)")
            asyncWriteGuessForCells(atPositions: atPositions, withAnswer: withAnswer)
            
            if withIdentifier.contains("fillInUnitCells") == false {
                highlightGuesses(for: [.equal, .conflict])
            
                if let guess = withAnswer {
                    atPositions.forEach {
                        moves += removePossibleNotesAfterGuess(guess, atCell: $0)
                    }
                }
            }
            
            if mutatesMoveHistory && moves.count > 0 {
                moveHistory.makeMoves(moves)
            }
            
            // check to see if this entry solved the puzzle
            checkPuzzleIsSolved()
        }
    }
    
    private func setNotesForCells(atPositions: [CellPosition], withNotes notes: [Int]?, overridePossibility: [CellNotePossibility]? = nil, mutatesMoveHistory: Bool = true, withIdentifier: String = #function) {
        // (1) make the changes in memory
        var moves = [Move]()
        
        for cell in atPositions {
            if let notes = notes {
                // if the note is not nil, then update the notes for the passed in cells
                for (arrayIndex, note) in notes.enumerated() {
                    let noteIndex = note - 1
                    
                    // we will allow an override if one was passed. But first, check to make sure the count lines up
                    // override is currently only used when loaded from viewDidLoad
                    let currentNotePossibility = userCellNotePossibilities[cell.row][cell.col][noteIndex]
                    let newNotePossibility: CellNotePossibility
                    if let possibleOverride = overridePossibility, possibleOverride.count == notes.count {
                        newNotePossibility = possibleOverride[arrayIndex]
                    } else {
                        let notePossibilityMode = (entryMode == .noteImpossible ? CellNotePossibility.impossible : .possible)
                        newNotePossibility = (currentNotePossibility == notePossibilityMode ? .none : notePossibilityMode)
                    }
                    userCellNotePossibilities[cell.row][cell.col][noteIndex] = newNotePossibility
                    
                    moves.append((cell, .note(number: note, fromPossibility: currentNotePossibility.rawValue, toPossibility: newNotePossibility.rawValue)))
                }
            } else {
                // if the note is nil, then we are setting everything to nothing again
                for noteIndex in 0..<puzzle.size {
                    let note = noteIndex + 1
                    let currentNotePossibility = userCellNotePossibilities[cell.row][cell.col][noteIndex]
                    userCellNotePossibilities[cell.row][cell.col][noteIndex] = .none
                    
                    if currentNotePossibility != .none {
                        moves.append((cell, .note(number: note, fromPossibility: currentNotePossibility.rawValue, toPossibility: CellNotePossibility.none.rawValue)))
                    }
                }
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
        }
        
        if mutatesMoveHistory && moves.count > 0 {
            moveHistory.makeMoves(moves)
        }
    }
    
    // MARK: - Private Helper Functions
    private func processMoveHistory(forMoves moves: [Move], moveDirection direction: MoveDirection) {
        var notesToSet: Dictionary<CellPosition, Dictionary<Int, CellNotePossibility>> = [:]
        
        // loop through the moves made
        for move in moves {
            switch move.moveType {
            case let .guess(from, to):
                let changeToValue = (direction == .undo ? from : to)
                setGuessForCells(atPositions: [move.cell], withAnswer: changeToValue, mutatesMoveHistory: false)
                selectedCell = gridRowStacks[move.cell.row].rowCells[move.cell.col]
                entryMode = .guessing
                
            case let .note(number, fromPossibility, toPossibility):
                let changeToPossibility: CellNotePossibility
                
                if direction == .undo {
                    changeToPossibility = CellNotePossibility(rawValue: fromPossibility) ?? .none
                } else {
                    changeToPossibility = CellNotePossibility(rawValue: toPossibility) ?? .none
                }
                
                var cellChangeSet = notesToSet[move.cell] ?? [:]
                cellChangeSet[number] = changeToPossibility
                notesToSet[move.cell] = cellChangeSet
            }
        }
        
        notesToSet.keys.forEach {
            setNotesForCells(atPositions: [$0], withNotes: Array(notesToSet[$0]!.keys), overridePossibility: Array(notesToSet[$0]!.values), mutatesMoveHistory: false)
        }
    }
    
    private func segueToStore() {
        DebugUtil.print("Seguing to the puzzle store from puzzle grid")
        performSegue(withIdentifier: "Puzzle Store Segue", sender: self)
    }
    
    private func identifyCellPositionForCellContainerView(_ cell: CellContainerView) -> CellPosition? {
        if let rowContainer = cell.superview as? GridRowView {
            let cellCol = rowContainer.subviews.firstIndex(of: cell)!
            let cellRow = gridRowStacks.firstIndex(of: rowContainer)!
            
            return CellPosition(row: cellRow, col: cellCol, puzzleSize: puzzle.size)
        } else {
            return nil
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
    let realmQueue = DispatchQueue(label: "\(AppSecrets.domainRoot).realmQueue", qos: .userInitiated)
    private func asyncWriteNotesForCells(atPositions: [CellPosition]) {
        let puzzleSize = puzzle.size
        // (1) get a dictionary mapping of the notes we need to save with their respective positions
        var notesToSave = Dictionary<CellPosition, [CellNotePossibility]>()
        
        for cell in atPositions {
            notesToSave[cell] = userCellNotePossibilities[cell.row][cell.col]
        }
        
        // (2) dispatch onto another queue
        realmQueue.async {
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
                
            } catch let error {
                error.report()
                fatalError("Error trying to async save the cell notes: \(error)")
            }
        }
    }
    
    private func asyncWriteGuessForCells(atPositions: [CellPosition], withAnswer: Int?) {
        let puzzleSize = puzzle.size
        
        realmQueue.async {
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
            } catch let error {
                error.report()
                fatalError("Error trying to save guess for cell:\n\(error)")
            }
        }
    }
    
    private func incrementPlayerPuzzleProgress() {
        // make sure we have a new puzzle id
        setNextPuzzleId()
        
        // write this as the active puzzle to realm
        do {
            try realm.write {
                playerProgress.activePuzzleId = nextPuzzleId ?? 0
            }
        } catch let error {
            error.report()
            fatalError("Error moving the user to the new puzzle ID:\n\(error)")
        }
        
        // the next puzzle has been set. We can mark it as nil
        nextPuzzleId = nil
    }
    
    private func setPuzzleProgress(to: Bool) {
        puzzleProgress.setInProgress(to: to, withRealm: realm)
    }

    private func consumePuzzleAllowance() {
        DebugUtil.print("Consuming a puzzle allowance")
        if let allowance = realm.objects(Allowances.self).filter("allowanceId = '\(AllowanceTypes.puzzle)'").first {
            allowance.decrementAllowance(by: 1, withRealm: realm)
        }
    }
    
    // MARK: - Puzzle Setup Functions
    private func updateColorTheme() {
        mainView.backgroundColor = ColorTheme.sharedInstance.background
        successOverlayBackgroundView.backgroundColor = ColorTheme.sharedInstance.background
        puzzleCompleteLabel.textColor = ColorTheme.sharedInstance.puzzleCompleteAndCountdown
        bestTimeTitle.textColor = ColorTheme.sharedInstance.fonts
        bestTimeLabel.textColor = ColorTheme.sharedInstance.fonts
        yourTimeTitle.textColor = ColorTheme.sharedInstance.fonts
        finalTimeLabel.textColor = ColorTheme.sharedInstance.fonts
        gameTimerBackground.setNeedsDisplay()
        gameTimerLabel.textColor = ColorTheme.sharedInstance.fonts
        gridRowStacks.forEach {
            $0.rowCells.forEach {
                $0.resetBackgroundColor()
                $0.cell.setNeedsDisplay()
            }
        }
    }
    
    private func resetCellNotesAndGuesses() {
        // (0) reset selections and set guessing mode back to guessing
        selectedCell = nil
        entryMode = .guessing
        
        // (1) build an array of CellPositions that matches the size of the puzzle
        var cellPositions = [CellPosition]()
        
        for cellId in 0..<(puzzle.size * puzzle.size) {
            cellPositions.append(CellPosition(cellId: cellId, puzzleSize: puzzle.size))
        }
        
        // (2) use said array to set all of the values for notes and guesses to nil
        setGuessForCells(atPositions: cellPositions, withAnswer: nil, mutatesMoveHistory: false)
        setNotesForCells(atPositions: cellPositions, withNotes: nil, mutatesMoveHistory: false)
        
        // (3) reset the move history
        moveHistory.reset()
    }
    
    private func writePuzzleToGrid() {
        // looped through cells
        var cellAllegiances = [CellPosition: (north: Bool, east: Bool, south: Bool, west: Bool)]()
        
        // set cage boundaries - loop until the puzzle size squared
        for cell in 0..<(puzzle.size * puzzle.size) {
            // set the x,y coordinates for when we need to set the view
            // let cellPosition: (row: Int, col: Int) = (cell / puzzle.size, cell % puzzle.size)
            let cellPosition = CellPosition(cellId: cell, puzzleSize: puzzle.size)
            
            if let cellNeighborAllegience = puzzle.neighborsInSameCageForCell(cellPosition) {
                cellAllegiances[cellPosition] = cellNeighborAllegience
                
                let cellView = gridRowStacks[cellPosition.row].rowCells[cellPosition.col].cell
                
                // empty out the hintText
                cellView.hint = nil
                
                // if we were able to get a cellView and its allegiences, then set the borders
                cellView.topBorder = (cellPosition.row == 0 ? .other : (cellNeighborAllegience.north ? .friend : .foe))
                
                cellView.rightBorder = (cellPosition.col == puzzle.size - 1 ? .other : (cellNeighborAllegience.east ? .friend : .foe))
                
                cellView.bottomBorder = (cellPosition.row == puzzle.size - 1 ? .other : (cellNeighborAllegience.south ? .friend : .foe))
                
                cellView.leftBorder = (cellPosition.col == 0 ? .other : (cellNeighborAllegience.west ? .friend : .foe))
                
                // reset my corner patches
                cellView.topLeftCornerPatch = false
                cellView.topRightCornerPatch = false
                cellView.bottomRightCornerPatch = false
                cellView.bottomLeftCornerPatch = false
                
                // look back to see if we need to patch any corners
                if let topLeftCellPosition = cellPosition.relativeCell(byRow: -1, byCol: -1),
                    let topLeftAllegiance = cellAllegiances[topLeftCellPosition] {
                    
                    if topLeftAllegiance.east == false && topLeftAllegiance.south == false && cellNeighborAllegience.north == true && cellNeighborAllegience.west == true {
                        DebugUtil.print("Adding a top left corner patch to cell: \(cellPosition.cellId)")
                        cellView.topLeftCornerPatch = true
                    }
                    
                    if topLeftAllegiance.east == true && topLeftAllegiance.south == true && cellNeighborAllegience.north == false && cellNeighborAllegience.west == false {
                        DebugUtil.print("Adding a bottom right corner patch to cell: \(topLeftCellPosition.cellId)")
                        gridRowStacks[topLeftCellPosition.row].rowCells[topLeftCellPosition.col].cell.bottomRightCornerPatch = true
                    }
                }
                
                if let topRightCellPosition = cellPosition.relativeCell(byRow: -1, byCol: 1),
                    let topRightAllegiance = cellAllegiances[topRightCellPosition] {
                    
                    if topRightAllegiance.west == false && topRightAllegiance.south == false && cellNeighborAllegience.north == true && cellNeighborAllegience.east == true {
                        DebugUtil.print("Adding a top right corner patch to cell: \(cellPosition.cellId)")
                        cellView.topRightCornerPatch = true
                    }
                    
                    if topRightAllegiance.west == true && topRightAllegiance.south == true && cellNeighborAllegience.north == false && cellNeighborAllegience.east == false {
                        DebugUtil.print("Adding a bottom left corner patch to cell: \(topRightCellPosition.cellId)")
                        gridRowStacks[topRightCellPosition.row].rowCells[topRightCellPosition.col].cell.bottomLeftCornerPatch = true
                    }
                }
            }
        }
        
        for key in puzzle.cages.keys {
            if let cage = puzzle.cages[key] {
                let cell = CellPosition(row: cage.firstCell / puzzle.size, col: cage.firstCell % puzzle.size, puzzleSize: puzzle.size)
                // let cell: (row: Int, col: Int) = (cage.firstCell / puzzle.size, cage.firstCell % puzzle.size)
                gridRowStacks[cell.row].rowCells[cell.col].cell.hint = puzzle.cages[key]?.hintText ?? "#ERR#"
            }
        }
    }
    
    private func hideUnneededRowsAndCells() {
        gridRowStacks[0..<puzzle.size].forEach{ $0.subviews[puzzle.size..<9].forEach{ $0.isHidden = true } }
        gridRowStacks[puzzle.size..<9].forEach{ $0.isHidden = true }
    }
    
    // MARK: - View Lifecycle State Changes
    private func setStatesToViewDisappear() {
        removeCountdownTimer()
        
        if [TimerState.stopped, .final, .reset].contains(timerState) == false {
            timerState = .pause
        }
    
        if gameState == .playing {
            gameState = .paused
        }
    }
    
    private func setStatesToViewAppear() {
        if gameState != .finished {
            if timerState == .stopped {
                startCountdownTimer()
            } else {
                timerState = .start
                gameState = .playing
            }
        }
    }
    
    // MARK: - View Lifecycle
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DebugUtil.print("")
        
        setStatesToViewDisappear()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DebugUtil.print("")
        
        setStatesToViewAppear()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DebugUtil.print("")
        
        // update all of the color themes
        updateColorTheme()
        
        // fill in the unit cells (give me cells)
        fillInUnitCells()
        
        // highlight conflicting and equal guesses
        highlightGuesses(for: [.equal, .conflict])
    }
    override func loadView() {
        super.loadView()
        CellViewElementValues.sharedInstance.clear()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        DebugUtil.print("")
        hideUnneededRowsAndCells()
        writePuzzleToGrid()
        
        // check to see if the puzzle is in progress - it is the only way we'd have something to load
        if puzzleProgress.inProgress == true {
            // will want to write the saved state to the grid here
            for savedGuess in puzzleProgress.puzzleGuesses.filter("guess != nil") {
                let cellPos = CellPosition(cellId: savedGuess.cellId, puzzleSize: puzzle.size)
                setGuessForCells(atPositions: [cellPos], withAnswer: savedGuess.guess.value, mutatesMoveHistory: false)
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
                    
                    setNotesForCells(atPositions: [cellPos], withNotes: noteInts, overridePossibility: notePossibility, mutatesMoveHistory: false)
                }
            }
            
            // set the saved paused game timer
            gameTimer = playerProgress.pausedGameTimer
            timer.adjustAccumulatedTime(to: playerProgress.pausedGameTimer)
        } else {
            // the puzzle is not in progress, so reset the guess and notes
            // TODO: we will eventually want to add some logic to this else statement so that it does not always execute
            resetCellNotesAndGuesses()
            
            // set the puzzle to in progress
            setPuzzleProgress(to: true)
            
            // since this is a new puzzle, then we will need to consume a puzzle allowance
            consumePuzzleAllowance()
        }
        
        // configure the timer callback
        timer.setUpdateCallback { [weak self] in
            self?.updateTimer()
        }
        
        // check if ads are supposed to be enabled
        if PuzzleProducts.adsEnabled == false || AnalyticsWrapper.isEU {
            // if ads are not to be enabled, then hide the ad view
            bannerView.isHidden = true
            bannerViewHeight.constant = 0
            bannerView.layoutIfNeeded()
        } else {
            // if ads are supposed to be show, then load and display an add
            // configure banner view ads
            bannerView.adUnitID = AppKeys.adMobPuzzleBannerAdId.key
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
        }
        
        // register notification observers
        observerTokens.append(NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification,
                                               object: nil, queue: nil) { [weak self] notification in
            
            self?.view.subviews.forEach({$0.layer.removeAllAnimations()})
            self?.view.layer.removeAllAnimations()
            self?.view.layoutIfNeeded()
            self?.setStatesToViewDisappear()
        })
        observerTokens.append(NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                               object: nil, queue: nil) { [weak self] notification in
                                                
            self?.setStatesToViewAppear()
        })
        observerTokens.append(NotificationCenter.default.addObserver(forName: UIApplication.willChangeStatusBarOrientationNotification,
                                               object: nil, queue: nil) { _ in
            CellViewElementValues.sharedInstance.clear()
        })
    }
    
    deinit {
        // unregister the notification observers
        observerTokens.forEach { NotificationCenter.default.removeObserver($0) }
    }
}

// MARK: - Extension for timer related methods
extension PuzzleViewController {
    private func startCountdownTimer() {
        let countLabel = UILabel()
        let startingFont = UIFont(name: "Noteworthy-Bold", size: 200.0)
        
        countLabel.tag = countdownTag
        countLabel.backgroundColor = .clear
        countLabel.textColor = ColorTheme.sharedInstance.puzzleCompleteAndCountdown
        countLabel.font = startingFont
        countLabel.textAlignment = .center
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(countLabel)
        
        let widthConstraint = NSLayoutConstraint(item: countLabel,
                                                 attribute: NSLayoutConstraint.Attribute.width,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: nil,
                                                 attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                 multiplier: 1,
                                                 constant: 500)
        let heightConstraint = NSLayoutConstraint(item: countLabel,
                                                  attribute: NSLayoutConstraint.Attribute.height,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil,
                                                  attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1,
                                                  constant: 250)
        
        // Center Horizontally
        var constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[superview]-(<=1)-[label]",
            options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
            metrics: nil,
            views: ["superview":puzzleGridSuperview!, "label":countLabel])
        
        view.addConstraints(constraints)
        
        // Center Vertically
        constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:[superview]-(<=1)-[label]",
            options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
            metrics: nil,
            views: ["superview":puzzleGridSuperview!, "label":countLabel])
        
        view.addConstraints(constraints)
        
        view.addConstraints([ widthConstraint, heightConstraint])
        
        let animation = {
            countLabel.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
            countLabel.alpha = 0.0
        }
        
        let animationReset = {
            countLabel.transform = .identity
            countLabel.alpha = 1.0
        }
        
        // temporarily disable the gesture recognizers
        puzzleGridSuperview.gestureRecognizers?.forEach {
            $0.isEnabled = false
        }
        
        countLabel.text = "3"
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
            animation()
        }, completion: { finished in
            animationReset()
            countLabel.text = "2"
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
                animation()
            }, completion: { finished in
                animationReset()
                countLabel.text = "1"
                
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
                    animation()
                }, completion: { [weak self] finished in
                    // done counting down. start the timer, enable interactions
                    if finished {
                        self?.timerState = .start
                        self?.gameState = .playing
                    }
                    // enable the gesture recognizers
                    self?.puzzleGridSuperview.gestureRecognizers?.forEach {
                        $0.isEnabled = true
                    }
                    
                    // set the label to say "GO!" an then remove the label from the super view
                    animationReset()
                    countLabel.text = "GO"
                    UIView.animate(withDuration: 1.25, delay: 0.0, options: .curveEaseIn, animations: {
                        animation()
                    }, completion: { _ in
                        countLabel.removeFromSuperview()
                    })
                })
            })
        })
    }
    
    private func createTimeString(from time: Double) -> String {
        let timerComponents = TimeInterval(time).components
        return String(format: "%02i:%02i:%02i", timerComponents.hours, timerComponents.minutes, timerComponents.seconds)
    }
    
    private func removeCountdownTimer() {
        view.viewWithTag(countdownTag)?.removeFromSuperview()
        view.layoutIfNeeded()
    }
    
    private func startTimer() {
        timer.start()
        timerState = .running
    }
    
    @objc private func updateTimer() {
        gameTimer += 1
    }
    
    private func resetTimer() {
        timer.reset()
        gameTimer = 0.0
        timerState = .stopped
    }
    
    private func pauseTimer() {
        timer.stop()
        saveTimerProgress()
    }
    
    /// Save the timer to Realm to track progress when application loses focus.
    private func saveTimerProgress() {
        // save the timer progress to realm
        playerProgress.setPausedGameTimer(to: timer.runningTime)
    }
    
    /// Save the timer to the 'leaderboard' as a final count
    private func saveFinalTimer() {
        // save final timer to realm
        let puzzleSolved = playerProgress.puzzlesSolved.filter("puzzleId == \(playerProgress.activePuzzleId)")
        
        if puzzleSolved.count == 0 {
            // if the puzzleSolved is 0 count, then we need to create a new one
            try! realm.write {
                let newPuzzleSolved = PuzzlesSolved()
                newPuzzleSolved.puzzleId = playerProgress.activePuzzleId
                playerProgress.puzzlesSolved.append(newPuzzleSolved)
            }
        }
        
        puzzleSolved.first?.markPuzzlePlayed(finalTime: timer.runningTime, withRealm: realm)
    }
}
