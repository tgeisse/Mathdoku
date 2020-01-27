//
//  ViewControllerExtensions.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 6/11/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit
import SwiftyStoreKit

extension UIViewController {
    func alertWithTitle(_ title: String, message: String, buttonLabel: String = "OK") -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonLabel, style: .cancel, handler: nil))
        return alert
    }
    
    func alertWithTwoButtons(title: String, message: String,
                             cancelButtonTitle: String, cancelStyle: UIAlertAction.Style = .cancel,
                             successButtonTitle: String, successStyle: UIAlertAction.Style = .default,
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
            @unknown default:
                DebugUtil.print("unknown result")
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
    
    func alertOutOfPuzzlesAndCanPurchase(mentionRefreshPeriod: Bool, messageOverride: String? = nil, actionOnConfirm: @escaping () -> ()) -> UIAlertController {
        DebugUtil.print("Creating alert")
        if SwiftyStoreKit.canMakePayments {
            DebugUtil.print("Making alert - can make payments")
            let message = (mentionRefreshPeriod ? "You have run out of puzzles. Either wait for your next daily refresh or purchase a puzzle pack." :
                "You have run out of puzzles. Purchase more to keep playing!")
            let cancelButtonTitle = (mentionRefreshPeriod ? "Wait Until Tomorrow" : "Decide Later")
            DebugUtil.print("Returning created alert")
            return alertWithTwoButtons(title: "Out of Puzzles",
                                       message: messageOverride ?? message,
                                       cancelButtonTitle: cancelButtonTitle, cancelStyle: .cancel,
                                       successButtonTitle: "Buy Puzzles", successStyle: .default,
                                       actionOnConfirm: actionOnConfirm)
        } else {
            DebugUtil.print("Returning created alert - cannot make payments")
            return alertWithTitle("Out of Puzzles", message: "You have run out of puzzles, but your account cannot make purchases. Please wait for your next daily refresh!")
        }
    }
}
