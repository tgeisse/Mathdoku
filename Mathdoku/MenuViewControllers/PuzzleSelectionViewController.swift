//
//  PuzzleSelectionViewController.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/26/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyUserDefaults

infix operator ~>: AdditionPrecedence

class PuzzleSelectionViewController: UIViewController {
    lazy var realm: Realm = {try! Realm()}()
    lazy var playerProgress: Results<PlayerProgress> = {
        realm.objects(PlayerProgress.self).sorted(byKeyPath: "puzzleSize", ascending: true)
    }()
    
    var selectedPuzzleSize: Int = -1 {
        didSet{
            PuzzleLoader.sharedInstance.preloadPuzzle(forSize: selectedPuzzleSize, withPuzzleId: activePuzzleId)
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
    
    private var puzzleAllowanceNotification: NotificationToken?
    
    // MARK: - IBOutlets
    @IBOutlet weak var startPuzzle: UIButton!
    @IBOutlet weak var puzzlesRemainingLabel: UILabel!
    
    @IBOutlet weak var inProgress3: UILabel!
    @IBOutlet weak var inProgress4: UILabel!
    @IBOutlet weak var inProgress5: UILabel!
    @IBOutlet weak var inProgress6: UILabel!
    @IBOutlet weak var inProgress7: UILabel!
    @IBOutlet weak var inProgress8: UILabel!
    @IBOutlet weak var inProgress9: UILabel!
    
    @IBOutlet var puzzleSizeButtons: [UIButton]! {
        didSet {
            puzzleSizeButtons.sort {
                $0.tag < $1.tag
            }
        }
    }
    
    @IBOutlet weak var updateButton: UIButton! {
        didSet {
            updateButton.titleLabel?.minimumScaleFactor = 0.0
            updateButton.titleLabel?.adjustsFontSizeToFitWidth = true
            updateButton.titleLabel?.textAlignment = .center
        }
    }
   
    // MARK: - View Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        updateStartButtonTitle()
        updateProgressMarkers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            navigationController?.overrideUserInterfaceStyle = [ColorTheme.Themes.darkMode, .midnight].contains(ColorTheme.sharedInstance.theme) ? .dark : .light
            navigationController?.navigationBar.overrideUserInterfaceStyle = [ColorTheme.Themes.darkMode, .midnight].contains(ColorTheme.sharedInstance.theme) ? .dark : .light
        }

        // Set up and configure a few aspects of the UI
        // DebugUtil.print(Realm.Configuration.defaultConfiguration.fileURL!)
        updateStartButtonTitle()
        updatePuzzlesRemainingLabel()
        addAllowanceNotification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DebugUtil.print("Puzzle Refresh Mode: \(PuzzleProducts.puzzleRefreshMode)")
        
        // see if we can get a new refresh allowawnce
        switch PuzzleProducts.puzzleRefreshMode {
        case .error(let error): DebugUtil.print("Error getting the puzzle refresh mode: \(error)")
        case .purchase, .freeUser:
            DebugUtil.print("Entering refresh grant block for free users")
            let puzzlesGranted = PuzzlePurchase.grantDailyPuzzleAllowance(withRealm: realm)
            
            if puzzlesGranted > 0 && Defaults[\.dailyRefreshNotice] {
                // puzzles were granted, notify the user
                let alert = self.alertWithTitle("More Puzzles!", message: "We've added \(puzzlesGranted) puzzle\(puzzlesGranted == 1 ? "" : "s") to your stash.", buttonLabel: "Game on!")
                self.showAlert(alert)
            }
        }
        
        checkForUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    // MARK: - UI Updates
    func updatePuzzlesRemainingLabel() {
        puzzlesRemainingLabel.text = "You have \(PuzzleProducts.puzzleAllowance.allowance) puzzles remaining."
        
    }
    
    func updateStartButtonTitle() {
        if (selectedPuzzleSize < 3 || selectedPuzzleSize > 9) == false {
            startPuzzle.setTitle(playerProgress[selectedPuzzleSize - 3].puzzleProgress?.inProgress == true ? "Continue Puzzle" : "Start Puzzle", for: .normal)
        }
    }
    
    func addAllowanceNotification() {
        puzzleAllowanceNotification = PuzzleProducts.puzzleAllowance.observe { [weak self] change in
            switch change {
            case .change:
                self?.updatePuzzlesRemainingLabel()
            case .error(let error):
                DebugUtil.print("An error occurred on the puzzle allowance notifications:\n\(error)")
            case .deleted:
                DebugUtil.print("The object was deleted.")
            }
        }
    }
    
    func checkForUpdates() {
        if !updateButton.isHidden { return }
        
        DispatchQueue.global(qos: .utility).async {
            if AppStoreInfo.sharedInstance.updateAvailable {
                DispatchQueue.main.async { [weak self] in
                    self?.displayUpdateButton(animated: true)
                }
            }
        }
    }
    
    // MARK: - Private methods for UI Updates
    private func updateInProgressMarker(forLabel label: UILabel, show: Bool) {
        label.isHidden = !show
    }
    
    private func updateProgressMarkers() {
        updateInProgressMarker(forLabel: inProgress3, show: playerProgress[0].puzzleProgress?.inProgress ?? false)
        updateInProgressMarker(forLabel: inProgress4, show: playerProgress[1].puzzleProgress?.inProgress ?? false)
        updateInProgressMarker(forLabel: inProgress5, show: playerProgress[2].puzzleProgress?.inProgress ?? false)
        updateInProgressMarker(forLabel: inProgress6, show: playerProgress[3].puzzleProgress?.inProgress ?? false)
        updateInProgressMarker(forLabel: inProgress7, show: playerProgress[4].puzzleProgress?.inProgress ?? false)
        updateInProgressMarker(forLabel: inProgress8, show: playerProgress[5].puzzleProgress?.inProgress ?? false)
        updateInProgressMarker(forLabel: inProgress9, show: playerProgress[6].puzzleProgress?.inProgress ?? false)
    }
    
    private func displayUpdateButton(animated: Bool) {
        let title = " Update Available"
        
        if !animated {
            updateButton.setTitle(title, for: .normal)
            updateButton.isHidden = false
            return
        }
        
        updateButton.transform = .identity
        updateButton.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        updateButton.setTitle("", for: .normal)
        updateButton.isHidden = false
        
        let animation1 = UIViewPropertyAnimator(duration: 0.15, curve: .easeIn) { [weak self] in
            self?.updateButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }
        
        let animation2 = UIViewPropertyAnimator(duration: 0.15, curve: .easeOut) { [weak self] in
            self?.updateButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            self?.view.layoutIfNeeded()
        }
        
        let animation3 = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut){ [weak self] in
            self?.updateButton.setTitle(title, for: .normal)
            self?.view.layoutIfNeeded()
        }
    
        animation1 ~> animation2 ~> animation3 //~> animation4
        animation1.startAnimation()
    }
    
    // MARK: - Button Actions
    @IBAction func redoUpdateAnimation(_ sender: UIButton) {
        updateButton.isHidden = true
        displayUpdateButton(animated: true)
    }
    
    @IBAction func puzzleSelection(_ sender: UIButton) {
        if let senderString = sender.currentTitle, let numberPressed = Int(senderString) {
            selectedPuzzleSize = numberPressed
            selectedButton = sender
            updateStartButtonTitle()
        }
    }
    
    @IBAction func openUrlForUpdate(_ sender: UIButton) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let appStoreUrl = AppStoreInfo.sharedInstance.storeInfo[.appStoreUrl],
                  let appStoreLink = URL(string: appStoreUrl) else {
                    
                      DispatchQueue.main.async { [weak self] in
                          guard let self = self else { return }
                          self.showAlert(self.alertWithTitle("Error Opening App Store", message: "There was an error trying to load the AppStore link from the update button."))
                      }
                      return
                    }
            
            DispatchQueue.main.async {
                DebugUtil.print("Opening app store: \(appStoreUrl)")
                UIApplication.shared.open(appStoreLink)
            }
        }
    }
    
    // MARK: - In-App Purchase methods
    func segueToStore() {
        DebugUtil.print("Seguing to the puzzle store")
        performSegue(withIdentifier: "Store Segue", sender: self)
    }
    
    // MARK: - Navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "PuzzleSelection" {
            guard selectedPuzzleSize >= 3 && selectedPuzzleSize <= 9 else { return false }
            
            let allowance = PuzzleProducts.puzzleAllowance
            if (playerProgress[selectedPuzzleSize - 3].puzzleProgress?.inProgress ?? false) || allowance.allowance == AllowanceTypes.puzzle.infiniteAllowance() || allowance.allowance > 0 {
                
                // if the player was already playing the puzzle or they have infinite plays
                // or they have puzzles left, then perform the segue
                return true
            } else {
                // else the player does not have puzzle allowance to play. Prompt to buy or wait
                // let mentionRefresh: Bool = PuzzleProducts.userIsFree
                
                AnalyticsWrapper.logEvent(.selectContent, contentType: .presented, id: "id-mainMenuOutOfPuzzles")
                
                let alert = self.alertOutOfPuzzlesAndCanPurchase(actionOnConfirm: segueToStore)
                self.showAlert(alert)
                
                return false
            }
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
                CrashWrapper.notifyException(name: .cast, reason: "Destination did not load as PuzzleViewController")
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            puzzleViewController.puzzle = PuzzleLoader.sharedInstance.fetchPuzzle(forSize: selectedPuzzleSize, withPuzzleId: activePuzzleId)
        }
    }
    
    deinit {
        puzzleAllowanceNotification?.invalidate()
    }
}

// MARK: - Extension for Keyboard input
extension PuzzleSelectionViewController {
    // MARK: - Keyboard Input
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        // if keyboard input is disabled, then return
        guard Defaults[\.enableKeyboardInput] else { return }
        
        guard let key = presses.first?.key else { return }
        DebugUtil.print("Key pressed: \(key.characters)")
        
        switch key.keyCode {
        case .keyboard3, .keypad3: selectPuzzleSize(forNumber: 3)
        case .keyboard4, .keypad4: selectPuzzleSize(forNumber: 4)
        case .keyboard5, .keypad5: selectPuzzleSize(forNumber: 5)
        case .keyboard6, .keypad6: selectPuzzleSize(forNumber: 6)
        case .keyboard7, .keypad7: selectPuzzleSize(forNumber: 7)
        case .keyboard8, .keypad8: selectPuzzleSize(forNumber: 8)
        case .keyboard9, .keypad9: selectPuzzleSize(forNumber: 9)
        case .keyboardLeftArrow: arrowKeyPressed(direction: .left)
        case .keyboardRightArrow: arrowKeyPressed(direction: .right)
        case .keypadEnter, .keyboardReturnOrEnter:
            if shouldPerformSegue(withIdentifier: "PuzzleSelection", sender: self) {
                performSegue(withIdentifier: "PuzzleSelection", sender: self)
            }
        default: super.pressesBegan(presses, with: event)
        }
    }
    
    // MARK: - Private functions to assist with keyboard input processing
    private func selectPuzzleSize(forNumber num: Int) {
        guard num >= 3 && num <= 9 else { return }
        puzzleSelection(puzzleSizeButtons[num - 3])
    }
    
    private func arrowKeyPressed(direction: KeyboardDirection) {
        switch direction {
        case .up, .down: return
        case .left:
            if selectedPuzzleSize == -1 { selectPuzzleSize(forNumber: 9) }
            else { selectPuzzleSize(forNumber: selectedPuzzleSize - 1) }
        case .right:
            if selectedPuzzleSize == -1 { selectPuzzleSize(forNumber: 3) }
            else { selectPuzzleSize(forNumber: selectedPuzzleSize + 1) }
        }
    }
}
