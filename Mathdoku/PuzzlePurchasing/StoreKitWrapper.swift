//
//  StoreKitWrapper.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 1/13/22.
//  Copyright © 2022 Taylor Geisse. All rights reserved.
//

import Foundation
import StoreKit

typealias StoreKitRequestCompletionHandler = (_ success: Bool, _ product: [SKProduct]?) -> Void
typealias StoreKitPurchaseCompletionHandler = (_ response: StoreKitPurchaseResponse) -> Void

enum StoreKitPurchaseResponse {
    case purchased
    case failed
    case restored
}

class StoreKitWrapper: NSObject {
    // MARK: - Singleton
    static let sharedInstance = StoreKitWrapper()
    
    // MARK: - Private Class Properties
    private var requests = [String : SKRequest]()
    private var completionHandlers = [String : StoreKitRequestCompletionHandler]()
    
    // MARK: - Public Class Properties
    var canMakePayments: Bool { return SKPaymentQueue.canMakePayments() }
    
    // MARK: - Retrieving Product Info
    func requestProductInfo(forProducts products: [String], completionHandler: StoreKitRequestCompletionHandler? = nil) {
        DebugUtil.print("Sending request for product info for products: \(products)")
        CrashWrapper.leaveBreadcrumb("Product info request", withType: .request, withMetadata: ["Products" : products])
        
        let combinedRequestName = products.sorted().reduce("", +)
        DebugUtil.print("Combined name: \(combinedRequestName)")
        
        cancelAndClearDetails(forProduct: combinedRequestName)
        completionHandlers[combinedRequestName] = completionHandler
        
        // create a new request and send it
        requests[combinedRequestName] = SKProductsRequest(productIdentifiers: Set(products))
        requests[combinedRequestName]!.delegate = self
        requests[combinedRequestName]!.start()
    }
    
    func requestProductInfo(_ product: String, completionHandler: StoreKitRequestCompletionHandler? = nil) {
        DebugUtil.print("Sending request for product info for product: \(product)")
        CrashWrapper.leaveBreadcrumb("Single product info request", withType: .request, withMetadata: ["Product" : product])
        
        // clear out the old request, if one exists and set the new completion handler
        cancelAndClearDetails(forProduct: product)
        completionHandlers[product] = completionHandler
        
        // create the new request and send it
        requests[product] = SKProductsRequest(productIdentifiers: [product])
        requests[product]!.delegate = self
        requests[product]!.start()
    }
    
    // MARK: - Product Purchasing
    /*
    func purchaseProduct(_ product: SKProduct) {
        DebugUtil.print("Purchasing product: \(product.productIdentifier)")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    } */
    
    // MARK: - Private helper functions
    private func cancelAndClearDetails(forProduct product: String) {
        requests[product]?.cancel()
        requests[product] = nil
        completionHandlers[product] = nil
    }
}

// MARK: - Product Info Request Response Delegate Extension
extension StoreKitWrapper: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DebugUtil.print("Received a Product Request response for \(response.products.count) products")
        
        let combinedRequestName = response.products.sorted(by: { $0.productIdentifier < $1.productIdentifier }).reduce("") { $0 + $1.productIdentifier }
        DebugUtil.print("Combined name: \(combinedRequestName)")
        completionHandlers[combinedRequestName]?(true, response.products)
        cancelAndClearDetails(forProduct: combinedRequestName)
    }
    
    // TODO: Determine what needs to be processed when a failure occurs
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DebugUtil.print("Failed to receive Product Information: \(error.localizedDescription)")
        CrashWrapper.leaveBreadcrumb("Failed to receive product info", withType: .request)
        CrashWrapper.notifyError(error, severity: .warning)
    }
}

/*
// MARK: - Payment Transaction Observer
extension StoreKitWrapper: SKPaymentTransactionObserver {
    // MARK: - Payment Observer Protocol
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for  transaction in transactions {
            switch transaction.transactionState {
            case .purchased: break
            case .failed:
                if let skerror = transaction.error as? SKError { DebugUtil.print("Could convert") }
                else { DebugUtil.print("Could not convert") }
            case .restored: break
            case .deferred: break
            case .purchasing: DebugUtil.print("Payment initiated: \(transaction.payment.productIdentifier)")
            @unknown default:
                DebugUtil.print("A new transaction state has entered the picture: \(transaction.transactionState.debugDescription)")
                CrashWrapper.notifyException(name: .transactionState, reason: "A new transaction state has entered the picture: \(transaction.transactionState.debugDescription)", severity: .warning)
            }
        }
    }
    
    // MARK: - Private functions to process a payment observation
    private func observedPurchased(productIdentifier pId: String) {
        
    }
    
    private func observedFailure(productIdentifier pId: String, error: Error) {
        
    }
    
    private func observedRestored(productIdentifier pId: String) {
        
    }
}
*/
