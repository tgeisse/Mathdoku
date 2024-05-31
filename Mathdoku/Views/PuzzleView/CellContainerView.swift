//
//  CellContainerView.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 5/2/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit

class CellContainerView: UIView {

    var cell: CellView {
        guard let returnValue = self.subviews.last as? CellView else {
            CrashWrapper.notifyException(name: .cast, reason: "A view other than a CellView made it into my subviews at the last position")
            fatalError("A view other than a CellView made it into my subviews at the last position")
        }
        
        return returnValue
    }
    
    var colorTheme = ColorTheme.sharedInstance
    
    // MARK: - Hightlight State
    enum HighlightState {
        case unselected
        case selected
        case friendly
        case possibleNote
        case impossibleNote
        
        @available(*, deprecated, message: "Moving to a function color scheme to allow overriding")
        var color: UIColor {
            switch self {
            case .unselected: return .clear
            case .selected: return ColorTheme.sharedInstance.selectedCell
            case .friendly: return ColorTheme.sharedInstance.friendlyCell
            case .possibleNote: return ColorTheme.sharedInstance.possibleNoteCellSelected
            case .impossibleNote: return ColorTheme.sharedInstance.impossibleNoteCellSelected
            }
        }
    }
    
    func getHighlightColor(forState state: HighlightState) -> UIColor {
        switch state {
        case .unselected: return colorTheme.background
        case .selected: return colorTheme.selectedCell
        case .friendly: return colorTheme.friendlyCell
        case .possibleNote: return colorTheme.possibleNoteCellSelected
        case .impossibleNote: return colorTheme.impossibleNoteCellSelected
        }
    }
    
    private let highlightTransitionTime: TimeInterval = 0.25
    var currentHighlightState = HighlightState.unselected {
        didSet {
            if oldValue != currentHighlightState {
                // if we have changed values, then animate
                animateBackgroundColor(getHighlightColor(forState: currentHighlightState), duration: highlightTransitionTime)
            }
        }
    }
    
    func resetBackgroundColor() {
        backgroundColor = getHighlightColor(forState: currentHighlightState)
    }
    
    // MARK: - Validation States
    enum ValidationState {
        case notValidating
        case valid
        case invalid
        
        @available(*, deprecated, message: "Moving to a function color scheme to allow overriding")
        var color: UIColor {
            switch self {
            case .notValidating: return .clear
            case .valid: return ColorTheme.sharedInstance.validCell
            case .invalid: return ColorTheme.sharedInstance.invalidCell
            }
        }
    }
    
    func getValidationColor(forState state: ValidationState) -> UIColor {
        switch state {
        case .notValidating: return .clear
        case .valid: return colorTheme.validCell
        case .invalid: return colorTheme.invalidCell
        }
    }
    
    private let flashValidationViewTransitionTime: TimeInterval = 0.7
    var currentValidationState = ValidationState.notValidating {
        didSet {
            if currentValidationState != .notValidating {
                animateCellValidationView(color: getValidationColor(forState: currentValidationState), duration: flashValidationViewTransitionTime)
            }
        }
    }    
    
    // MARK: - Background Animations
    private func animateBackgroundColor(_ color: UIColor?,
                                duration: TimeInterval,
                                options: UIView.AnimationOptions = [.allowUserInteraction, .beginFromCurrentState],
                                completion: ((Bool) -> Void)? = nil) {
        
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
            self.backgroundColor = color
        }, completion: completion)
    }
    
    private func animateCellValidationView(color: UIColor,
                               duration: TimeInterval) {
        
        let validationAnimtationView = UIView()
        validationAnimtationView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        validationAnimtationView.backgroundColor = UIColor.clear
        validationAnimtationView.isUserInteractionEnabled = false
        self.insertSubview(validationAnimtationView, belowSubview: cell)
        
        UIView.animate(withDuration: duration, animations: {
            validationAnimtationView.backgroundColor = color
        }, completion: { _ in
            UIView.animate(withDuration: duration, animations: {
                validationAnimtationView.backgroundColor = .clear
            }, completion: { fin in
                validationAnimtationView.removeFromSuperview()
            })
        })
    }
}
