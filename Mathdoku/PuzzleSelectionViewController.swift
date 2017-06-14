//
//  PuzzleSelectionViewController.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/26/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit
import RealmSwift

class PuzzleSelectionViewController: UIViewController {
    let puzzleLoader = PuzzleLoader()
    lazy var realm: Realm = {try! Realm()}()
    lazy var playerProgress: Results<PlayerProgress> = {
        try! Realm().objects(PlayerProgress.self).sorted(byKeyPath: "puzzleSize", ascending: true)
    }()
    lazy var puzzleAllowance: Allowances? = {
        try! Realm().objects(Allowances.self).filter("allowanceId == '\(AllowanceTypes.puzzle.id())'").first
    }()
    
    var selectedPuzzleSize: Int = -1 {
        didSet{
            puzzleLoader.preloadPuzzleForSize(selectedPuzzleSize, withPuzzleId: activePuzzleId)
        }
    }
    var selectedButton: UIButton? {
        didSet {
            oldValue?.backgroundColor = UIColor.white
            selectedButton?.backgroundColor = selectColor
            startPuzzle.isEnabled = selectedButton != nil
        }
    }
    var activePuzzleId: Int {
        return playerProgress[selectedPuzzleSize - 3].activePuzzleId
    }
    
    private let selectColor = UIColor(red: 1.0, green: 0.9648, blue: 0.60, alpha: 1.0)
    
    @IBOutlet weak var startPuzzle: UIButton!
    @IBOutlet weak var puzzlesRemainingLabel: UILabel!
    
    private var puzzleAllowanceNotification: NotificationToken?
   
    // MARK: - View Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStartButtonTitle()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up and configure a few aspects of the UI
        DebugUtil.print(Realm.Configuration.defaultConfiguration.fileURL!)
        updateStartButtonTitle()
        updatePuzzlesRemainingLabel()
        addAllowanceNotification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // see if we can get a new weekly allowawnce (if we are in weekly allowance mode)
        switch PuzzleProducts.getPuzzleRefreshMode() {
        case .error(let error): DebugUtil.print("Error getting the puzzle refresh mode: \(error)")
        case .purchase: break
        case .weekly:
            DebugUtil.print("Entering weekly refresh grant block")
            if PuzzlePurchase.weeklyPuzzleAllowanceGrantAvailable(withPuzzleAllowance: puzzleAllowance, withRealm: realm) {
                
                DebugUtil.print("Weekly grant is available -- processing")
                let puzzlesGranted = PuzzlePurchase.grantWeeklyPuzzleAllowance(withPuzzleAllowance: puzzleAllowance, withRealm: realm)
                if puzzlesGranted > 0 {
                    let alert = self.alertWithTitle("Weekly Puzzle Refill!", message: "We've added \(puzzlesGranted) puzzle\(puzzlesGranted == 1 ? "" : "s") to your stash.", buttonLabel: "Game on!")
                    self.showAlert(alert)
                }
            }
        }
    }
    
    // MARK: - UI Updates
    func updatePuzzlesRemainingLabel(allowance passedAllowance: Allowances? = nil) {
        let allowance = passedAllowance ?? puzzleAllowance
        
        if allowance != nil {
            puzzlesRemainingLabel.text = "You have \(allowance!.allowance) puzzles remaining."
        } else {
            // if we were not able to load a puzzle allowance, then don't display the label
            puzzlesRemainingLabel.text = ""
        }
    }
    
    func updateStartButtonTitle() {
        if (selectedPuzzleSize < 3 || selectedPuzzleSize > 9) == false {
            startPuzzle.setTitle(playerProgress[selectedPuzzleSize - 3].puzzleProgress?.inProgress == true ? "Continue Puzzle" : "Start Puzzle", for: .normal)
        }
    }
    
    func addAllowanceNotification() {
        if let puzzleAllowance = realm.objects(Allowances.self).filter("allowanceId == '\(AllowanceTypes.puzzle.id())'").first {
            puzzleAllowanceNotification = puzzleAllowance.addNotificationBlock { [weak self] change in
                switch change {
                case .change(_):
                    self?.updatePuzzlesRemainingLabel(allowance: puzzleAllowance)
                case .error(let error):
                    DebugUtil.print("An error occurred on the puzzle allowance notifications:\n\(error)")
                case .deleted:
                    DebugUtil.print("The object was deleted.")
                }
            }
        }
    }
    
    // MARK: - Button Actions
    @IBAction func puzzleSelection(_ sender: UIButton) {
        if let senderString = sender.currentTitle, let numberPressed = Int(senderString) {
            selectedPuzzleSize = numberPressed
            selectedButton = sender
            updateStartButtonTitle()
        }
    }
    
    // MARK: - In-App Purchase methods
    func initiateIAPTransaction() {
        DebugUtil.print("Initiating an in app purchase")
        
    }
    
    func segueToStore() {
        DebugUtil.print("Seguing to the puzzle store")
        performSegue(withIdentifier: "Store Segue", sender: self)
    }
    
    // MARK: - Navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "PuzzleSelection" {
            if let allowance = puzzleAllowance {
                if (playerProgress[selectedPuzzleSize - 3].puzzleProgress?.inProgress ?? false) || allowance.allowance == AllowanceTypes.puzzle.infiniteAllowance() || allowance.allowance > 0{
                    
                    // if the player was already playing the puzzle or they have infinite plays
                    // or they have puzzles left, then perform the segue
                    return true
                } else {
                    // else the player does not have puzzle allowance to play. Prompt to buy or wait
                    let alert = self.alertWithTwoButtons(title: "Out of Puzzles", message: "You have run out of puzzles. Either wait for your next weekly refresh or purchase a puzzle pack.", cancelButtonTitle: "Wait Until Next Week", successButtonTitle: "Buy Puzzles", actionOnConfirm: segueToStore)
                    self.showAlert(alert)
                    
                    return false
                }
            } else {
                // we don't have a puzzle allowance - this should not happen
                return false
            }
            
            /*
            if let allowance = puzzleAllowance {
                let puzzleRemaining = allowance.allowance - allowance.consumed
                
                if (playerProgress[selectedPuzzleSize - 3].puzzleProgress?.inProgress ?? false) || puzzleRemaining > 0 || allowance.allowance == AllowanceTypes.puzzle.infiniteAllowance() {
                    return true
                }
            }
            
            // if we have reached this point, then they do not have an allowance or they have run out of puzzles
            let alert: UIAlertController
            if SwiftyStoreKit.canMakePayments {
                alert = self.alertWithTwoButtons(title: "Out of Puzzles",
                                                 message: "In order to keep this app ad-free, we rely on puzzle purchases. Sadly, you have run out of puzzles and need to purchase more.",
                                                 cancelButtonTitle: "Cancel",
                                                 successButtonTitle: "Buy more",
                                                 actionOnConfirm: initiateIAPTransaction)
            } else {
                alert = self.alertWithTitle("Out of Puzzles", message: "You do not have any more puzzles, but your account settings do not let you purchase more.")
            }
            self.showAlert(alert)
            
                
            return false*/
        } else {
            return true
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "PuzzleSelection" {
            guard let puzzleViewController = segue.destination as? PuzzleViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            puzzleViewController.puzzle = puzzleLoader.loadNewPuzzleForSize(selectedPuzzleSize, withPuzzleId: activePuzzleId)
            puzzleViewController.puzzleLoader = puzzleLoader
            
            // print("I am segueing to a new puzzle of size \(newPuzzleForSize.size), and that was after the button for \(puzzleSize) was interpretted as \(puzzleSizeAsInt)")
        }
    }
    
    deinit {
        puzzleAllowanceNotification?.stop()
    }
}

