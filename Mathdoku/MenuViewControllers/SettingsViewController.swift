//
//  SettingsViewController.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 11/14/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UITableViewController {
    @IBOutlet weak var singleCellNoteTakingSwitch: UISwitch! {
        didSet {
            singleCellNoteTakingSwitch.setOn(Defaults[.singleNoteCellSelection], animated: false)
        }
    }
    
    @IBOutlet weak var updateNotesAutomaticallySwitch: UISwitch! {
        didSet {
            updateNotesAutomaticallySwitch.setOn(Defaults[.clearNotesAfterGuessEntry], animated: false)
        }
    }
    
    @IBOutlet weak var rotateAfterGuessSwitch: UISwitch! {
        didSet {
            rotateAfterGuessSwitch.setOn(Defaults[.rotateAfterCellEntry], animated: false)
        }
    }
    
    @IBOutlet weak var highlightSimilarGuessesSwitch: UISwitch! {
        didSet {
            highlightSimilarGuessesSwitch.setOn(Defaults[.highlightSameGuessEntry], animated: false)
        }
    }
    
    @IBOutlet weak var highlightConflictingGuessSwitch: UISwitch! {
    didSet {
    highlightConflictingGuessSwitch.setOn(Defaults[.highlightConflictingEntries], animated: false)
    }
}
    
    @IBOutlet weak var fillInGiveMeSwitch: UISwitch! {
        didSet{
            fillInGiveMeSwitch.setOn(Defaults[.fillInGiveMes], animated: false)
        }
    }
    
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        DebugUtil.print("Switching on tag \(sender.tag)")
        let settingName: String
        let settingVariant: String
        
        switch sender.tag {
        case 1:
            // single cell toggle
            Defaults[.singleNoteCellSelection] = singleCellNoteTakingSwitch.isOn
            settingName = "singleCell"
            settingVariant = "\(Defaults[.singleNoteCellSelection])"
        case 2:
            Defaults[.clearNotesAfterGuessEntry] = updateNotesAutomaticallySwitch.isOn
            settingName = "autoNotes"
            settingVariant = "\(Defaults[.clearNotesAfterGuessEntry])"
        case 3:
            Defaults[.rotateAfterCellEntry] = rotateAfterGuessSwitch.isOn
            settingName = "rotateCell"
            settingVariant = "\(Defaults[.rotateAfterCellEntry])"
        case 4:
            Defaults[.highlightSameGuessEntry] = highlightSimilarGuessesSwitch.isOn
            settingName = "highlightSame"
            settingVariant = "\(Defaults[.highlightSameGuessEntry])"
        case 5:
            Defaults[.highlightConflictingEntries] = highlightConflictingGuessSwitch.isOn
            settingName = "highlightConflict"
            settingVariant = "\(Defaults[.highlightConflictingEntries])"
        case 6:
            Defaults[.fillInGiveMes] = fillInGiveMeSwitch.isOn
            settingName = "fillInGiveMes"
            settingVariant = "\(Defaults[.fillInGiveMes])"
        default:
            settingName = "default"
            settingVariant = "none"
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id-toggleSetting",
            AnalyticsParameterItemName: settingName,
            AnalyticsParameterItemVariant: settingVariant
            ])
    }
}
