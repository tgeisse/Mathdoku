//
//  SettingsViewController.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 11/14/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyUserDefaults

class SettingsViewController: UITableViewController {
    @IBOutlet weak var colorThemeTableViewCell: UITableViewCell!
    @IBOutlet weak var colorThemeLabel: UILabel!
    
    @IBOutlet weak var multipleCellNoteTakingSwitch: UISwitch! {
        didSet {
            multipleCellNoteTakingSwitch.setOn(!Defaults[\.singleNoteCellSelection], animated: false)
        }
    }
    
    @IBOutlet weak var updateNotesAutomaticallySwitch: UISwitch! {
        didSet {
            updateNotesAutomaticallySwitch.setOn(Defaults[\.clearNotesAfterGuessEntry], animated: false)
        }
    }
    
    @IBOutlet weak var rotateAfterGuessSwitch: UISwitch! {
        didSet {
            rotateAfterGuessSwitch.setOn(Defaults[\.rotateAfterCellEntry], animated: false)
        }
    }
    
    @IBOutlet weak var highlightSimilarGuessesSwitch: UISwitch! {
        didSet {
            highlightSimilarGuessesSwitch.setOn(Defaults[\.highlightSameGuessEntry], animated: false)
        }
    }
    
    @IBOutlet weak var highlightConflictingGuessSwitch: UISwitch! {
    didSet {
    highlightConflictingGuessSwitch.setOn(Defaults[\.highlightConflictingEntries], animated: false)
    }
}
    
    @IBOutlet weak var fillInGiveMeSwitch: UISwitch! {
        didSet {
            fillInGiveMeSwitch.setOn(Defaults[\.fillInGiveMes], animated: false)
        }
    }
    
    @IBOutlet weak var doubleTapNoteModeSwitch: UISwitch! {
        didSet {
            doubleTapNoteModeSwitch.setOn(Defaults[\.doubleTapToggleNoteMode], animated: false)
        }
    }
    
    @IBOutlet weak var dailyPuzzleNotices: UISwitch! {
        didSet {
            dailyPuzzleNotices.setOn(Defaults[\.dailyRefreshNotice], animated: false)
        }
    }
    
    @IBOutlet weak var allowKeyboardInputs: UISwitch! {
        didSet {
            allowKeyboardInputs.setOn(Defaults[\.enableKeyboardInput], animated: false)
        }
    }
    
    @IBOutlet weak var drawFriendlyBorder: UISwitch! {
        didSet {
            drawFriendlyBorder.setOn(Defaults.drawFriendlyBorder, animated: false)
        }
    }
    
    @IBOutlet weak var startingCountdownTimer: UISwitch! {
        didSet {
            startingCountdownTimer.setOn(Defaults.enableStartCountdownTimer, animated: false)
        }
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        DebugUtil.print("Switching on tag \(sender.tag)")
        let settingName: String
        let settingVariant: String
        
        switch sender.tag {
        case 1:
            // single cell toggle
            Defaults[\.singleNoteCellSelection] = !multipleCellNoteTakingSwitch.isOn
            settingName = "singleCell"
            settingVariant = "\(!multipleCellNoteTakingSwitch.isOn)"
        case 2:
            Defaults[\.clearNotesAfterGuessEntry] = updateNotesAutomaticallySwitch.isOn
            settingName = "autoNotes"
            settingVariant = "\(Defaults[\.clearNotesAfterGuessEntry])"
        case 3:
            Defaults[\.rotateAfterCellEntry] = rotateAfterGuessSwitch.isOn
            settingName = "rotateCell"
            settingVariant = "\(Defaults[\.rotateAfterCellEntry])"
        case 4:
            Defaults[\.highlightSameGuessEntry] = highlightSimilarGuessesSwitch.isOn
            settingName = "highlightSame"
            settingVariant = "\(Defaults[\.highlightSameGuessEntry])"
        case 5:
            Defaults[\.highlightConflictingEntries] = highlightConflictingGuessSwitch.isOn
            settingName = "highlightConflict"
            settingVariant = "\(Defaults[\.highlightConflictingEntries])"
        case 6:
            Defaults[\.fillInGiveMes] = fillInGiveMeSwitch.isOn
            settingName = "fillInGiveMes"
            settingVariant = "\(Defaults[\.fillInGiveMes])"
        case 7:
            Defaults[\.doubleTapToggleNoteMode] = doubleTapNoteModeSwitch.isOn
            settingName = "doubleTapMode"
            settingVariant = "\(Defaults[\.doubleTapToggleNoteMode])"
        case 8:
            Defaults[\.dailyRefreshNotice] = dailyPuzzleNotices.isOn
            settingName = "dailyRefreshNotice"
            settingVariant = "\(dailyPuzzleNotices.isOn)"
        case 9:
            Defaults[\.enableKeyboardInput] = allowKeyboardInputs.isOn
            settingName = "enableKeyboardInput"
            settingVariant = "\(allowKeyboardInputs.isOn)"
        case 10:
            Defaults.drawFriendlyBorder = drawFriendlyBorder.isOn
            settingName = "drawFriendlyBorder"
            settingVariant = "\(drawFriendlyBorder.isOn)"
        case 11:
            Defaults.enableStartCountdownTimer = startingCountdownTimer.isOn
            settingName = "startCountdownTimer"
            settingVariant = "\(startingCountdownTimer.isOn)"
        default:
            settingName = "default"
            settingVariant = "none"
        }
        
        AnalyticsWrapper.logEvent(.selectContent, contentType: .userSetting, id: "id-toggleSetting", name: settingName, variant: settingVariant)
    }
    
    @IBAction func resetScoresButtonPress(_ sender: UIButton) {
        AnalyticsWrapper.logEvent(.selectContent, contentType: .userSetting, id: "id-resetGameTimesPrompted")
        
        let alert = self.alertWithTwoButtons(title: "Reset Game Times?", message: "Are you sure you want to reset your game times? This action cannot be undone.", cancelButtonTitle: "No", successButtonTitle: "Yes") { [weak self] in
            
            self?.resetGameTimeScores()
        }
        
        self.showAlert(alert)
    }
    
    private func resetGameTimeScores() {
        AnalyticsWrapper.logEvent(.selectContent, contentType: .userSetting, id: "id-resettingGameTimes")
        
        do {
            let realm = try Realm()
            
            // get the puzzles that need to be reset (times are not nil)
            let puzzlesPlayed = realm.objects(PuzzlesSolved.self).filter("timeToSolve != nil")
            DebugUtil.print("Identified \(puzzlesPlayed.count) puzzles that need to have their game times reset")
            
            try realm.write {
                // reset the puzzle times
                puzzlesPlayed.forEach {
                    $0.timeToSolve.value = nil
                }
            }
            
        } catch let error {
            error.report()
            fatalError("Error trying to reset game times:\n\(error)")
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 4 {
            let appVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            let buildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
            var secHeader = "VERSION \(appVersion) BUILD \(buildNumber)"
            
            #if DEBUG
            secHeader += " (DEBUG)"
            #endif
            
            return secHeader
        } else {
            return super.tableView(tableView, titleForHeaderInSection   : section)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        colorThemeLabel.text = "\(ColorTheme.sharedInstance.theme)"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        if cell == colorThemeTableViewCell {
            cell.setSelected(false, animated: true)
        }
        
        
    }
}
