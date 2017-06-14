//
//  AppDelegate.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/9/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // set up a purchase listener
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            
            for purchase in purchases {
                
                if purchase.transaction.transactionState == .purchased || purchase.transaction.transactionState == .restored {
                    
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("purchased: \(purchase)")
                }
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

        // Realm Migrations
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 3,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 3) {
                    // do nothing, just let Realm pick up the new configuration
                    
                }
                
        })
        
        Realm.Configuration.defaultConfiguration = config
        
        // load the configuration
        let realm = try! Realm()
        
        // set the default allowance values
        for allowanceType in Util.iterateEnum(AllowanceTypes.self) {
            // if we cannot get the default allowance, then we messed up somehow
            let defaultAllowance = allowanceType.defaultAllowance()
            
            // try to load the allowance value from Realm
            if let allowanceRecord = realm.objects(Allowances.self).filter("allowanceId == '\(allowanceType.id())'").first {
                // if we have a puzzle allowance, make sure it is greater than the default value
                // if it -1, however, that is because the user has 'unlimited' allowance
                if allowanceRecord.allowance != allowanceType.infiniteAllowance() && allowanceRecord.allowance < defaultAllowance {
                    // if it is less than the default allowance, then set it new
                    try! realm.write {
                        allowanceRecord.allowance = defaultAllowance
                    }
                }
            } else {
                // otherwise, we do not have an allowance of this type
                // add it to Realm
                try! realm.write {
                    let newAllowanceRecord = Allowances()
                    newAllowanceRecord.allowanceId = allowanceType.id()
                    newAllowanceRecord.allowance = allowanceType.defaultAllowance()
                    realm.add(newAllowanceRecord)
                }
            }

        }
        
        // set the default player progress / validate that none were lost
        let playerProgress = realm.objects(PlayerProgress.self)
        try! realm.write() {
            for puzzleSize in 3...9 {
                if playerProgress.filter("puzzleSize == \(puzzleSize)").count == 0{
                    let newPlayerProgress = PlayerProgress()
                    newPlayerProgress.puzzleSize = puzzleSize
                    newPlayerProgress.activePuzzleId = 0
                    newPlayerProgress.puzzleProgress = nil
                    realm.add(newPlayerProgress)
                }
                
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

