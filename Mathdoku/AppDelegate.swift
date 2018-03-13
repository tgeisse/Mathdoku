//
//  AppDelegate.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/9/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import GoogleMobileAds
import SwiftyStoreKit
import Bugsnag

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
                    DebugUtil.print("purchased: \(purchase)")
                }
            }
        }
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        AnalyticsWrapper.logEvent(.appOpen)
        
        // Initialize the Google Mobile Ads SDK.
        // AdMob app id
        GADMobileAds.configure(withApplicationID: AppKeys.adMobAppId.key)
        
        // Initialize Bugsnag SDK
        Bugsnag.start(withApiKey: AppKeys.bugsnagApiKey.key)
        // Bugsnag test notification
        // Bugsnag.notifyError(NSError(domain: AppSecrets.domainRoot, code: 408, userInfo: nil))
        
        return true
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

        // Realm Migrations
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 7,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 6) {
                    // introduced a play count to the PuzzlesSolved object - will set existing records to "1"
                    migration.enumerateObjects(ofType: PuzzlesSolved.className()) { oldOjbect, newObject in
                        newObject!["playCount"] = 1
                    }
                }
                
        })
        
        Realm.Configuration.defaultConfiguration = config
        
        // load the configuration
        let realm = try! Realm()
        
        // set the default player progress / validate that none were lost
        let playerProgress = realm.objects(PlayerProgress.self)
        for puzzleSize in 3...9 {
            if playerProgress.filter("puzzleSize == \(puzzleSize)").count == 0 {
                try! realm.write() {
                    let newPlayerProgress = PlayerProgress()
                    newPlayerProgress.puzzleSize = puzzleSize
                    newPlayerProgress.activePuzzleId = Int(arc4random_uniform(200)) + 200
                    newPlayerProgress.puzzleProgress = nil
                    realm.add(newPlayerProgress)
                }
            }
        }
        
        // set the default allowance values if they don't exist
        for allowanceType in Utility.iterateEnum(AllowanceTypes.self) {
            // test to see if we have an allowance for this type
            if realm.objects(Allowances.self).filter("allowanceId == '\(allowanceType)'").count == 0 {
                DebugUtil.print("Granting the initial allowance for \(allowanceType)")
                // if an allowance for this type does not exist, then let's add the default value
                try! realm.write {
                    let newAllowanceRecord = Allowances()
                    newAllowanceRecord.allowanceId = "\(allowanceType)"
                    newAllowanceRecord.allowance = allowanceType.initialAllowance
                    newAllowanceRecord.lastRefreshDate = NSDate()
                    realm.add(newAllowanceRecord)
                }
            }
        }
        
        // initiatile user defaults
        Settings.initialize()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        DebugUtil.print("app losing active focus")
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = window!.frame
        blurEffectView.tag = 221122
        
        self.window?.addSubview(blurEffectView)
            
        DebugUtil.print("blur overlay should have been added")
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
        DebugUtil.print("returning to app")
        /*
        if let blurEffectView = self.window?.viewWithTag(221122) {
            UIView.animate(withDuration: 0.5, animations: {
                blurEffectView.alpha = 0.0
            }, completion: { finished in
                blurEffectView.removeFromSuperview()
            })
        }*/
        self.window?.viewWithTag(221122)?.removeFromSuperview()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

