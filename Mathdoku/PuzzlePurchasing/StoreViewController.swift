//
//  StoreViewController.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 6/12/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit

class StoreViewController: UIViewController {
    @IBOutlet weak var puzzle100Title: UILabel!
    @IBOutlet weak var puzzle100Description: UILabel!
    @IBOutlet weak var puzzle100Buy: UIButton!
    private var puzzle100Product: SKProduct?

    @IBOutlet weak var puzzle1000Title: UILabel!
    @IBOutlet weak var puzzle1000Description: UILabel!
    @IBOutlet weak var puzzle1000Buy: UIButton!
    private var puzzle1000Product: SKProduct?
    
    @IBOutlet weak var puzzle100Container: StoreProductContainerView! {
        didSet {
            puzzle100Container.borderColor = UIColor.orange.cgColor
        }
    }
    @IBOutlet weak var puzzle1000Container: StoreProductContainerView! {
        didSet {
            puzzle1000Container.borderColor = UIColor.orange.cgColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // load the product details for puzzle100
        if let loadedPuzzle = PuzzleProducts.getLoadedPuzzleProductInfo(productId: PuzzleProducts.puzzle100.productIdentifier) {
            // if this details are already loaded, then use what is in memory
            puzzle100Title.text = loadedPuzzle.title
            puzzle100Description.text = loadedPuzzle.description
            puzzle100Buy.setTitle("Buy for \(loadedPuzzle.price)", for: .normal)
            puzzle100Buy.isEnabled = true
            puzzle100Product = loadedPuzzle.product
        } else {
            // if it isn't loaded, then let's get the information from the store
            SwiftyStoreKit.retrieveProductsInfo([PuzzleProducts.puzzle100.productIdentifier]) { [weak self] results in
                if let product = results.retrievedProducts.first {
                    self?.puzzle100Title.text = product.localizedTitle
                    self?.puzzle100Description.text = product.localizedDescription
                    self?.puzzle100Buy.setTitle("Buy for \(product.localizedPrice!)", for: .normal)
                    self?.puzzle100Buy.isEnabled = true
                    self?.puzzle100Product = product
                    
                    // save the details in case the page is loaded again
                    PuzzleProducts.setPuzzleProductInfo(
                        productInfo: LoadedProduct(product: product,
                                                   title: product.localizedTitle,
                                                   description: product.localizedDescription,
                                                   price: product.localizedPrice!))
                }
                for invalidProductId in results.invalidProductIDs {
                    DebugUtil.print("Could not retrieve product info. Invalid product identifier: \(invalidProductId)")
                }
                if let error = results.error {
                    DebugUtil.print("Error: \(error)")
                }
            }
        }
        
        // load the product details for puzzle1000
        if let loadedPuzzle = PuzzleProducts.getLoadedPuzzleProductInfo(productId: PuzzleProducts.puzzle1000.productIdentifier) {
            // if this details are already loaded, then use what is in memory
            puzzle1000Title.text = loadedPuzzle.title
            puzzle1000Description.text = loadedPuzzle.description
            puzzle1000Buy.setTitle("Buy for \(loadedPuzzle.price)", for: .normal)
            puzzle1000Buy.isEnabled = true
            puzzle1000Product = loadedPuzzle.product
        } else {
            // if it isn't loaded, then let's get the information from the store
            SwiftyStoreKit.retrieveProductsInfo([PuzzleProducts.puzzle1000.productIdentifier]) { [weak self] results in
                if let product = results.retrievedProducts.first {
                    self?.puzzle1000Title.text = product.localizedTitle
                    self?.puzzle1000Description.text = product.localizedDescription
                    self?.puzzle1000Buy.setTitle("Buy for \(product.localizedPrice!)", for: .normal)
                    self?.puzzle1000Buy.isEnabled = true
                    self?.puzzle1000Product = product
                    
                    // save the details in case the page is loaded again
                    PuzzleProducts.setPuzzleProductInfo(
                        productInfo: LoadedProduct(product: product,
                                                   title: product.localizedTitle,
                                                   description: product.localizedDescription,
                                                   price: product.localizedPrice!))
                }
                for invalidProductId in results.invalidProductIDs {
                    DebugUtil.print("Could not retrieve product info. Invalid product identifier: \(invalidProductId)")
                }
                if let error = results.error {
                    DebugUtil.print("Error: \(error)")
                }
            }
        }
    }
    
    @IBAction func purchaseProduct(_ sender: UIButton) {
        if let label = sender.accessibilityLabel {
            switch label {
            case "puzzle100":
                if let product = puzzle100Product {
                    PuzzlePurchase.initiateIAPForPuzzleProduct(product, puzzleProduct: PuzzleProducts.puzzle100)
                }
            case "puzzle1000":
                if let product = puzzle1000Product {
                    PuzzlePurchase.initiateIAPForPuzzleProduct(product, puzzleProduct: PuzzleProducts.puzzle1000)
                }
            default: break
            }
        }
    }
    
}
