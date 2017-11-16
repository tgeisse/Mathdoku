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
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        switch sender.tag {
        case 1:
            // single cell toggle
            Defaults[.singleNoteCellSelection] = singleCellNoteTakingSwitch.isOn
        case 3:
            Defaults[.rotateAfterCellEntry] = rotateAfterGuessSwitch.isOn
        default:
            return
        }
    }
}
