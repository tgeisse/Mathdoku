//
//  ColorThemePreviewTableViewCell.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 12/8/20.
//  Copyright © 2020 Taylor Geisse. All rights reserved.
//

import UIKit

class ColorThemePreviewTableViewCell: UITableViewCell {
    @IBOutlet weak var themeTitle: UILabel!
    @IBOutlet weak var cell1: CellContainerView!
    @IBOutlet weak var cell2: CellContainerView!
    @IBOutlet weak var cell3: CellContainerView!
    @IBOutlet weak var cell4: CellContainerView!
    
    @IBOutlet var allCells: [CellContainerView]!
    
}
