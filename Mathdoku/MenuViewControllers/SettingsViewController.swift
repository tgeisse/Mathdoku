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
            DebugUtil.print("Will set the state of the Cell Note Taking switch")
        }
        
        willSet {
            DebugUtil.print("Cell Note Taking switch was changed")
        }
    }
    
}
