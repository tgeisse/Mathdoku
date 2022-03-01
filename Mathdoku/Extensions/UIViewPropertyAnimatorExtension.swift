//
//  UIViewPropertyAnimatorExtension.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 2/28/22.
//  Copyright © 2022 Taylor Geisse. All rights reserved.
//

import UIKit

// infix operator ~>: AdditionPrecedence

extension UIViewPropertyAnimator {
    @discardableResult static func ~>(lhs: UIViewPropertyAnimator, rhs: UIViewPropertyAnimator) -> UIViewPropertyAnimator {
        
        lhs.addCompletion { _ in
            rhs.startAnimation()
        }
        
        return rhs
    }
}
