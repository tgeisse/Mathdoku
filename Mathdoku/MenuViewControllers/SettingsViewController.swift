//
//  SettingsViewController.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 11/14/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit

// Defaults extension for settings variables
extension DefaultsKeys {
    static let singleNoteCellSelection = DefaultsKey<Bool>("singleNoteCellSelection")
    static let rotateAfterCellEntry = DefaultsKey<Bool>("rotateAfterCellEntry")
}

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
