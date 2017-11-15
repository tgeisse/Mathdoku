//
//  GridRowView.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 5/2/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit

class GridRowView: UIStackView {

    var rowCells: [CellContainerView] {
        guard let returnValue = self.subviews as? [CellContainerView] else {
            fatalError("A view that is not a CellCtonainerView made it into my subviews")
        }
        
        return returnValue
    }
}
