//
//  MathdokuButton.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 1/11/18.
//  Copyright © 2018 Taylor Geisse. All rights reserved.
//

import UIKit

class MathdokuButton: UIButton {

    var colorTheme: ButtonColor? {
        didSet {
            self.backgroundColor = colorTheme?.background
            self.titleLabel?.textColor = colorTheme?.text
        }
    }

}
