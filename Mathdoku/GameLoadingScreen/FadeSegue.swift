//
//  FadeSeque.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 1/28/18.
//  Copyright © 2018 Taylor Geisse. All rights reserved.
//

import UIKit

class FadeSegue: UIStoryboardSegue {
    override func perform() {
        // Get the view of the source
        guard let sourceViewControllerView = self.source.view else {
            self.source.present(self.destination, animated: false, completion: nil)
            return
        }
        // Get the view of the destination
        guard let destinationViewControllerView = self.destination.view else {
            self.source.present(self.destination, animated: false, completion: nil)
            return
        }
        
        let screenSize = UIScreen.main.bounds.size
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        // Make the destination view the size of the screen
        destinationViewControllerView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        
        // Insert destination below the source
        // Without this line the animation works but the transition is not smooth as it jumps from white to the new view controller
        destinationViewControllerView.alpha = 0;
        sourceViewControllerView.addSubview(destinationViewControllerView);
        // Animate the fade, remove the destination view on completion and present the full view controller
        UIView.animate(withDuration: 0.75, animations: {
            destinationViewControllerView.alpha = 1;
        }, completion: { (finished) in
            // sourceViewControllerView.alpha = 1
            self.source.present(self.destination, animated: false, completion: nil)
        })
    }
}
