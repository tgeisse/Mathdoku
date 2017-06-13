//
//  ViewControllerExtensions.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 6/11/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit

extension UIViewController {
    func alertWithTitle(_ title: String, message: String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
    
    func alertWithTwoButtons(title: String, message: String, cancelButtonTitle: String, successButtonTitle: String, actionOnConfirm: @escaping () -> ()) ->UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel))
        alert.addAction(UIAlertAction(title: successButtonTitle, style: .default, handler: { action in
            
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
        guard self.presentedViewController != nil else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
}
