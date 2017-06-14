//
//  PuzzlePurchase.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 6/11/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import RealmSwift
import UIKit
import StoreKit

typealias PuzzlePurchaseTuple = (product: SKProduct, buysAllowance: Int)

struct PuzzlePurchase {
    /*
    fileprivate static var loadedPuzzleProducts = [PuzzlePurchaseTuple]()
    
    static func purchaseOptionsAlertForLoadedProducts() -> UIAlertController {
        let alert = UIAlertController(title: "Select Puzzle Pack", message: "How many additional puzzles would you like?", preferredStyle: .actionSheet)
        
        for productTuple in loadedPuzzleProducts.sorted(by: { $0.buysAllowance < $1.buysAllowance })
        {
            alert.addAction(UIAlertAction(title: productTuple.product.localizedTitle + " - " + productTuple.product.localizedPrice!, style: .default, handler: { action in
                
                switch action.style {
                case .default:
                    DebugUtil.print("alert default case")
                    initiateIAPForPuzzleProduct(productTuple.product, buysAllowance: productTuple.buysAllowance)
                case .cancel:
                    DebugUtil.print("alert cancel case")
                case .destructive:
                    DebugUtil.print("alert destructive case")
                }
                
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel Purchase", style: .cancel))
        
        return alert
    } */
    
    static func initiateIAPForPuzzleProduct(_ product: SKProduct, buysAllowance: Int) {
        SwiftyStoreKit.purchaseProduct(product, atomically: true) { result in
            switch result {
            case .success(let purchase):
                DebugUtil.print("Purchase Success: \(purchase.productId)")
                do {
                    let realm = try Realm()
                    let currentAllowance = realm.objects(Allowances.self).filter("allowanceId == '\(AllowanceTypes.puzzle.id())'").first
                    
                    currentAllowance?.incrementAllowance(by: buysAllowance, withRealm: realm)
                    
                } catch (let error) {
                    DebugUtil.print("Unable to complete a purchase:\n\(error)")
                }
            case .error(let error):
                switch error.code {
                case .unknown: DebugUtil.print("Unknown error. Please contact support")
                case .clientInvalid: DebugUtil.print("Not allowed to make the payment")
                case .paymentCancelled: DebugUtil.print("Payment was cancelled")
                case .paymentInvalid: DebugUtil.print("The purchase identifier was invalid")
                case .paymentNotAllowed: DebugUtil.print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: DebugUtil.print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: DebugUtil.print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: DebugUtil.print("Could not connect to the network")
                case .cloudServiceRevoked: DebugUtil.print("User has revoked permission to use this cloud service")
                }
            }
        }
    }
//    
//    static func loadProductInfoForPuzzleProducts(_ products: [PuzzleProduct]) {
//        var productIdentifier = Set<String>()
//        var productIdToBuysAllowance = Dictionary<String, Int>()
//        products.forEach {
//            productIdentifier.insert($0.productIdentifier)
//            productIdToBuysAllowance[$0.productIdentifier] = $0.buysAllowance
//        }
//        
//        SwiftyStoreKit.retrieveProductsInfo(productIdentifier) { results in
//            for product in results.retrievedProducts {
//                if let buysAllowance = productIdToBuysAllowance[product.productIdentifier] {
//                    let newProductTuple: PuzzlePurchaseTuple
//                    newProductTuple.product = product
//                    newProductTuple.buysAllowance = buysAllowance
//                    
//                    loadedPuzzleProducts.append(newProductTuple)
//                    
//                    DebugUtil.print("Loaded product info for \(product.localizedTitle), message: \(product.localizedDescription) - \(product.localizedPrice!)")
//                }
//            }
//            for invalidProductId in results.invalidProductIDs {
//                
//                DebugUtil.print("Could not retrieve product info. Invalid product identifier: \(invalidProductId)")
//                
//            }
//            if let error = results.error {
//                DebugUtil.print("Error: \(error)")
//            }
//        }
//        
//    }
}
