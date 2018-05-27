//
//  PuzzleProducts.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 6/11/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import StoreKit
import RealmSwift

typealias PuzzleProduct = (productIdentifier: String, title: String, description: String, promotionalImage: UIImage, forAllowance: AllowanceTypes, buysAllowance: Int, disablesAds: Bool)

enum PuzzleRefreshMode {
    case purchase
    case freeUser
    case error(String)
}

struct PuzzleProducts {
    static let PuzzlePacks: [PuzzleProduct] = [
        ("\(AppSecrets.domainRoot).puzzle100", "100 Puzzles", "And no more ads!", #imageLiteral(resourceName: "GridImage"), .puzzle, 100, true),
        ("\(AppSecrets.domainRoot).puzzle250", "250 Puzzles", "And no more ads!", #imageLiteral(resourceName: "GridImage"), .puzzle, 250, true),
        ("\(AppSecrets.domainRoot).puzzle500", "500 Puzzles", "And no more ads!", #imageLiteral(resourceName: "GridImage"), .puzzle, 500, true),
        ("\(AppSecrets.domainRoot).puzzle1000", "1000 Puzzles", "And no more ads!", #imageLiteral(resourceName: "GridImage"), .puzzle, 1000, true)
    ]
    
    private static let loadedInfo = LoadedInformation()
    
    private class LoadedInformation {
        private let loadedProductsQueue = DispatchQueue(label: "\(AppSecrets.domainRoot).loadedProductsQueue",
                                                        qos: .default,
                                                        attributes: .concurrent)
        
        private var loadedProducts = Dictionary<String, SKProduct>()
        
        lazy var realm: Realm = {
            do {
                let localRealm = try Realm()
                return localRealm
            } catch (let error) {
                fatalError("Error creating a realm in PuzzleProducts.LoadedInformation:\n\(error)")
            }
        }()
        var puzzleAllowance: Allowances?
        
        func queryPuzzleAllowance() -> Allowances {
            puzzleAllowance = realm.objects(Allowances.self).filter("allowanceId = '\(AllowanceTypes.puzzle)'").first!
            return puzzleAllowance!
        }
        
        func setProduct(_ product: SKProduct, forIdentifier pId: String) {
            loadedProductsQueue.async (flags: .barrier) { [weak self] in
                self?.loadedProducts[pId] = product
            }
        }
        
        func getProduct(forIdentifier pId: String) -> SKProduct? {
            var product: SKProduct? = nil
            loadedProductsQueue.sync { [weak self] in
                product = self?.loadedProducts[pId]
            }
            return product
        }
    }
    
    static var userIsFree: Bool {
        switch puzzleRefreshMode {
        case .freeUser: return true
        default: return false
        }
    }
    
    static var userHasPurchased: Bool {
        switch puzzleRefreshMode {
        case .purchase: return true
        default: return false
        }
    }
    
    static var puzzleAllowance: Allowances {
        get {
            return loadedInfo.puzzleAllowance ?? loadedInfo.queryPuzzleAllowance()
        }
    }
    
    static var puzzleRefreshMode: PuzzleRefreshMode {
        if puzzleAllowance.lastPurchaseDate.timeIntervalSince1970 < puzzleAllowance.lastRefreshDate.timeIntervalSince1970 {
            return .freeUser
        } else {
            return .purchase
        }
    }
    
    static var adsEnabled: Bool {
        return !userHasPurchased
    }
    
    static func getLoadedPuzzleProduct(forIdentifier pId: String) -> SKProduct? {
        return loadedInfo.getProduct(forIdentifier: pId)
    }
    
    static func setLoadedPuzzleProduct(_ product: SKProduct, forIdentifier pId: String) {
        loadedInfo.setProduct(product, forIdentifier: pId)
    }
}
