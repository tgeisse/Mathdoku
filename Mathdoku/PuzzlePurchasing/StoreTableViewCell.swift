//
//  StoreTableViewCell.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 12/26/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit
import StoreKit

class StoreTableViewCell: UITableViewCell {
    // MARK: - Class properties
    private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var puzzleProduct: PuzzleProduct? = nil
    var product: SKProduct? = nil {
        didSet {
            if product == nil {
                addActivityIndicator()
            } else {
                removeActivityIndicator()
                updateBuyButton()   
            }
        }
    }

    // MARK: - IBOutlets
    @IBOutlet weak var promotionalImage: UIImageView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var buyButton: UIButton! {
        didSet {
            buyButton.titleLabel?.numberOfLines = 1
            buyButton.titleLabel?.adjustsFontSizeToFitWidth = true
            buyButton.titleLabel?.lineBreakMode = .byCharWrapping
        }
    }
    
    // MARK: - IBActions
    @IBAction func buyButtonPresses(_ sender: UIButton) {
        if let prod = product, let puzzProd = puzzleProduct {
            addActivityIndicator()
            PuzzlePurchase.initiateIAPForPuzzleProduct(prod, puzzleProduct: puzzProd) { [weak self] in
                
                self?.removeActivityIndicator()
                self?.updateBuyButton()
            }
        }
    }
    
    // MARK: - Button activity methods
    func addActivityIndicator() {
        buyButton.setTitle("", for: .normal)
        buyButton.isEnabled = false
        
        let halfButtonHeight = buyButton.bounds.size.height / 2
        let halfButtonWidth = buyButton.bounds.size.width / 2
        activityIndicator.center = CGPoint(x: halfButtonWidth, y: halfButtonHeight)
        
        buyButton.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }

    func removeActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    func updateBuyButton() {
        if let prod = product {
            buyButton.setTitle(prod.localizedPrice, for: .normal)
            buyButton.isEnabled = true
        } else {
            buyButton.setTitle("Unable to load", for: .normal)
            buyButton.isEnabled = false
        }
    }
}
