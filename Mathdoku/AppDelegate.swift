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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var sharingController: SharingController?

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
        
        // initialize sharingController
        sharingController = SharingController(databaseReference: Database.database().reference())

        return true
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

        // Realm Migrations
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 5,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 5) {
                    // do nothing, just let Realm pick up the new configuration
                }
                
        })
        
        Realm.Configuration.defaultConfiguration = config
        
        // load the configuration
        let realm = try! Realm()
        
        // set the default allowance values if they don't exist
        for allowanceType in Utility.iterateEnum(AllowanceTypes.self) {
            // test to see if we have an allowance for this type
            DebugUtil.print("Granting the initial allowance for \(allowanceType)")
            if realm.objects(Allowances.self).filter("allowanceId == '\(allowanceType)'").count == 0 {
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

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        switch userActivity.activityType {
        case NSUserActivityTypeBrowsingWeb:
            if let controller = sharingController, let url = userActivity.webpageURL {
                //TODO: show progress indicator

                controller.challenge(from: url).then { challenge -> () in
                    DebugUtil.print("Opening puzzle for \(challenge)")

                    if let navigationController = self.window?.rootViewController as? UINavigationController {
                        //TODO: show dialog with challenge.victoryTime before proceeding

                        let puzzleLoader = PuzzleLoader()
                        let puzzleViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PuzzleViewController") as! PuzzleViewController
                        puzzleViewController.puzzle = puzzleLoader.fetchPuzzle(forSize: challenge.puzzleSize, withPuzzleId: challenge.puzzleID)
                        puzzleViewController.puzzleLoader = puzzleLoader
                        navigationController.pushViewController(puzzleViewController, animated: true)
                    }

                }.catch { error in
                    DebugUtil.print("Failed to open challenge: \(error)")

                    if let navigationController = self.window?.rootViewController as? UINavigationController {
                        let alert = navigationController.alertWithTitle("Unable to Open Challenge", message: "Please check your network connection and try again.")
                        navigationController.visibleViewController?.showAlert(alert)
                    }

                }.always {
                    //TODO: hide progress indicator
                }
            }
            return true

        default:
            return false
        }
    }

}

