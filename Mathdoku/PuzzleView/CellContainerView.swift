//
//  CellContainerView.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 5/2/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit

class CellContainerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func initialize() {
        updateColorThemeElements()
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: SettingNotification.nightMode), object: nil, queue: nil) { [weak self] notification in
            self?.updateColorThemeElements()
            self?.cell.setNeedsDisplay()
        }
    }
    
    private func updateColorThemeElements() {
        backgroundColor = currentHighlightState.color
    }
    
    var cell: CellView {
        guard let returnValue = self.subviews.last as? CellView else {
            fatalError("A view other than a CellView made it into my subviews at the last position")
        }
        
        return returnValue
    }
    
    // MARK: - Hightlight State
    enum HighlightState {
        case unselected
        case selected
        case friendly
        case possibleNote
        case impossibleNote
        
        var color: UIColor {
            switch self {
            case .unselected: return ColorTheme.backgroundColor
            case .selected: return ColorTheme.orange.dark
            case .friendly: return ColorTheme.orange.light
            case .possibleNote: return ColorTheme.green.light
            case .impossibleNote: return ColorTheme.red.light
            }
        }
    }
    
    private let highlightTransitionTime: TimeInterval = 0.25
    var currentHighlightState = HighlightState.unselected {
        didSet {
            if oldValue != currentHighlightState {
                // if we have changed values, then animate
                animateBackgroundColor(currentHighlightState.color, duration: highlightTransitionTime)
            }
        }
    }
    
    // MARK: - Validation States
    enum ValidationState {
        case notValidating
        case valid
        case invalid
        
        var color: UIColor {
            switch self {
            case .notValidating: return UIColor.clear
            case .valid: return ColorTheme.green.light
            case .invalid: return ColorTheme.red.light
            }
        }
    }
    
    private let flashValidationViewTransitionTime: TimeInterval = 0.7
    var currentValidationState = ValidationState.notValidating {
        didSet {
            if currentValidationState != .notValidating {
                animateCellValidationView(color: currentValidationState.color, duration: flashValidationViewTransitionTime)
            }
        }
    }
    
    
    // MARK: - Background Animations
    private func animateBackgroundColor(_ color: UIColor?,
                                duration: TimeInterval,
                                options: UIViewAnimationOptions = [.allowUserInteraction, .beginFromCurrentState],
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
        }, completion: { finished in
            UIView.animate(withDuration: duration, animations: {
                validationAnimtationView.backgroundColor = ValidationState.notValidating.color
            }, completion: { fin in
                validationAnimtationView.removeFromSuperview()
            })
        })
    }
}
