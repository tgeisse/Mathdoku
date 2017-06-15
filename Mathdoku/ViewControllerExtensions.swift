//
//  ViewControllerExtensions.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 6/11/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit

extension UIViewController {
    func alertWithTitle(_ title: String, message: String, buttonLabel: String = "OK") -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonLabel, style: .cancel, handler: nil))
        return alert
    }
    
    func alertWithTwoButtons(title: String, message: String,
                             cancelButtonTitle: String, cancelStyle: UIAlertActionStyle = .cancel,
                             successButtonTitle: String, successStyle: UIAlertActionStyle = .default,
                             actionOnConfirm: @escaping () -> ()) ->UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: cancelButtonTitle, style: cancelStyle))
        alert.addAction(UIAlertAction(title: successButtonTitle, style: successStyle, handler: { action in
            
            switch action.style {
            case .default:
                DebugUtil.print("alert extension default case")
                actionOnConfirm()
            case .cancel:
                DebugUtil.print("alert extension cancel case")
            case .destructive:
                DebugUtil.print("alert extension destructive case")
            }
            
        }))
        
        
        return alert
    }
    
    func showAlert(_ alert: UIAlertController) {
        if navigationController?.visibleViewController == self {
            guard self.presentedViewController != nil else {
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
    }
    
    func alertOutOfPuzzlesAndCanPurchase(mentionWeeklyAllowance: Bool, actionOnConfirm: @escaping () -> ()) -> UIAlertController {
        let message = (mentionWeeklyAllowance ? "You have run out of puzzles. Either wait for your next weekly refresh or purchase a puzzle pack." :
                                                "You have run out of puzzles. Purchase more to keep playing!")
        let cancelButtonTitle = (mentionWeeklyAllowance ? "Wait Until Next Week" : "Decide Later")
        return alertWithTwoButtons(title: "Out of Puzzles",
                                   message: message,
                                   cancelButtonTitle: cancelButtonTitle, cancelStyle: .cancel,
                                   successButtonTitle: "Buy Puzzles", successStyle: .default,
                                   actionOnConfirm: actionOnConfirm)
    }
}
