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
    
    static func weeklyPuzzleAllowanceGrantAvailable(withPuzzleAllowance withAllowance: Allowances? = nil,
                                                    withRealm: Realm? = nil) -> Bool {
        
        let realm = try! withRealm ?? Realm()
        if let allowance = withAllowance ?? realm.objects(Allowances.self).filter("allowanceId == '\(AllowanceTypes.puzzle.id())'").first {
        
            return Date().timeIntervalSince(allowance.lastRefreshDate as Date).components.weeks > 0
        }
        return false
    }
    
    static func grantWeeklyPuzzleAllowance(withPuzzleAllowance withAllowance: Allowances? = nil,
                                           withRealm: Realm? = nil) -> Int {
        
        let realm = try! withRealm ?? Realm()
        if let allowance = withAllowance ?? realm.objects(Allowances.self).filter("allowanceId == '\(AllowanceTypes.puzzle.id())'").first {
            let weeksSinceLastRefresh = Date().timeIntervalSince(allowance.lastRefreshDate as Date).components.weeks
            
            let maxRefreshAllowed = AllowanceTypes.puzzle.maxRefreshPeriods() * AllowanceTypes.puzzle.defaultAllowance()
            
            let refreshAllowedByTime = AllowanceTypes.puzzle.defaultAllowance() * weeksSinceLastRefresh
            
            let allowanceToSetTo = min(maxRefreshAllowed, allowance.allowance + refreshAllowedByTime)
            
            let allowanceRefresh = allowanceToSetTo - allowance.allowance
            
            DebugUtil.print("Weeks since last refresh: \(weeksSinceLastRefresh) and granting \(allowanceRefresh) puzzles")
            
            if allowanceRefresh > 0 {
                allowance.incrementAllowance(by: allowanceRefresh, withRealm: realm)
            }
            
            if weeksSinceLastRefresh > 0 {
                try! realm.write {
                    allowance.lastRefreshDate = NSDate()
                }
            }
            
            return allowanceRefresh
        }
        
        return 0
    }
    
    static func initiateIAPForPuzzleProduct(_ product: SKProduct, puzzleProduct: PuzzleProduct) {
        SwiftyStoreKit.purchaseProduct(product, atomically: true) { result in
            switch result {
            case .success(let purchase):
                DebugUtil.print("Purchase Success: \(purchase.productId)")
                do {
                    let realm = try Realm()
                    let currentAllowance = realm.objects(Allowances.self).filter("allowanceId == '\(AllowanceTypes.puzzle.id())'").first
                    
                    currentAllowance?.incrementAllowance(by: puzzleProduct.buysAllowance, withRealm: realm)
                    try realm.write {
                        currentAllowance?.lastPurchaseDate = NSDate()
                    }
                } catch (let error) {
                    DebugUtil.print("Unable to complete a purchase: \(error)")
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
