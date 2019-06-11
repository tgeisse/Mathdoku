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
import SwiftyStoreKit

typealias PuzzlePurchaseTuple = (product: SKProduct, buysAllowance: Int)

struct PuzzlePurchase {
    static func grantDailyPuzzleAllowance(withRealm: Realm? = nil) -> Int {
        let realm = try! Realm()
        if let allowance = realm.objects(Allowances.self).filter("allowanceId == '\(AllowanceTypes.puzzle)'").first {
            let calendar = NSCalendar.current
            let lastRefreshDate = calendar.startOfDay(for: allowance.lastRefreshDate as Date)
            let today = calendar.startOfDay(for: Date())
            let daysBetween = calendar.dateComponents([.day], from: lastRefreshDate, to: today).day!
            
            let refreshPeriodGrants = min(AllowanceTypes.puzzle.maxRefreshGrants, daysBetween)
            
            DebugUtil.print("Days since last refresh: \(daysBetween) - refresh periods to be granted: \(refreshPeriodGrants)")
            
            if refreshPeriodGrants > 0 {
                // if we have periods to grant, then calculate the amount
                let grantAmount = refreshPeriodGrants * AllowanceTypes.puzzle.refreshAllowance
                
                DebugUtil.print("Granting \(grantAmount) additional puzzles")
                
                allowance.incrementAllowance(by: grantAmount, withRealm: realm)
                
                return grantAmount
            }
        }
        
        return 0
    }
    
    static func initiateIAPForPuzzleProduct(_ product: SKProduct, puzzleProduct: PuzzleProduct, completion: (() -> ())? = nil) {
        DebugUtil.print("Initiating a purchase for product \(puzzleProduct)")
        SwiftyStoreKit.purchaseProduct(product, atomically: true) { result in
            DebugUtil.print("Received results for attempted purchase of product \(puzzleProduct)")
            completion?()
            switch result {
            case .success(let purchase):
                DebugUtil.print("Purchase Success: \(purchase.productId)")
                do {
                    let realm = try Realm()
                    let currentAllowance = realm.objects(Allowances.self).filter("allowanceId == '\(AllowanceTypes.puzzle)'").first
                    
                    currentAllowance?.incrementAllowance(by: puzzleProduct.buysAllowance, withRealm: realm)
                    try realm.write {
                        currentAllowance?.lastPurchaseDate = NSDate()
                    }
                } catch let error {
                    error.report()
                    DebugUtil.print("Unable to complete a purchase: \(error)")
                }
                
                // mark the transactions as finished, if needed
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
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
                case .privacyAcknowledgementRequired: DebugUtil.print("Privacy Acknowledgement Required")
                case .unauthorizedRequestData: DebugUtil.print("Unauthorized Request Data")
                case .invalidOfferPrice: DebugUtil.print("Invalid Offer Price")
                case .invalidOfferIdentifier: DebugUtil.print("Invalid Offer Identifier")
                case .invalidSignature: DebugUtil.print("Invalid Signature")
                case .missingOfferParams: DebugUtil.print("Missing Offer Parameters")
                }
            }
        }
    }
}
