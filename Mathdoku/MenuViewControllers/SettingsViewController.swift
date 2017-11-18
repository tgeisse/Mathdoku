//
//  SettingsViewController.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 11/14/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet weak var singleCellNoteTakingSwitch: UISwitch! {
        didSet {
            singleCellNoteTakingSwitch.setOn(Defaults[.singleNoteCellSelection], animated: false)
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
    
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        DebugUtil.print("Switching on tag \(sender.tag)")
        switch sender.tag {
        case 1:
            // single cell toggle
            Defaults[.singleNoteCellSelection] = singleCellNoteTakingSwitch.isOn
        case 3:
            Defaults[.rotateAfterCellEntry] = rotateAfterGuessSwitch.isOn
        case 4:
            Defaults[.highlightSameGuessEntry] = highlightSimilarGuessesSwitch.isOn
        case 5:
            Defaults[.highlightConflictingEntries] = highlightConflictingGuessSwitch.isOn
        default:
            return
        }
    }
}
