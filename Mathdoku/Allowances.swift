//
//  PuzzleAllowance.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 6/5/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation
import RealmSwift

public enum AllowanceTypes {
    case puzzle
    
    func id() -> String {
        switch self {
        case .puzzle: return "puzzle"
        }
    }
    
    func defaultAllowance() -> Int {
        #if DEBUG
            switch self {
            case .puzzle: return 1
            }
        #else
            switch self {
            case .puzzle: return 3
            }
        #endif
    }
    
    func infiniteAllowance() -> Int { return -1 }
}

class Allowances: Object {
    dynamic var allowanceId = ""
    dynamic var consumed = 0
    dynamic var allowance = 0
    dynamic var lastPurchaseDate = NSDate(timeIntervalSince1970: 1)
    dynamic var lastRefreshDate = NSDate(timeIntervalSince1970: 1)
    
    override static func primaryKey() -> String? {
        return "allowanceId"
    }
    
    func incrementConsumption(by incrementBy: Int = 1, withRealm: Realm? = nil) {
        do {
            let realm = try withRealm ?? Realm()

            try realm.write {
                consumed = consumed + incrementBy
            }
        } catch (let error) {
            fatalError("Error incrementing consumption for '\(allowanceId)':\n\(error)")
        }
    }
    
    func incrementAllowance(by incrementBy: Int, withRealm: Realm? = nil) {
        do {
            let realm = try withRealm ?? Realm()
            
            try realm.write {
                allowance = allowance + incrementBy
            }
        } catch (let error) {
            fatalError("Error incrementing allowance '\(allowanceId)':\n\(error)")
        }
    }
    
    func decrementAllowance(by decrementBy: Int, withRealm: Realm? = nil) {
        do {
            let realm = try withRealm ?? Realm()
            
            try realm.write {
                allowance = allowance - decrementBy
            }
        } catch (let error) {
            fatalError("Error decrementing allowance '\(allowanceId)':\n\(error)")
        }
    }
    
    func playerHasPuzzleAllowance() -> Bool {
        return consumed < allowance
    }
}
