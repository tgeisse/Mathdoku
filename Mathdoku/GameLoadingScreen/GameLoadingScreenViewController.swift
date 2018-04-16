//
//  GameLoadingScreenViewController.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 1/28/18.
//  Copyright © 2018 Taylor Geisse. All rights reserved.
//

import UIKit
import RealmSwift

class GameLoadingViewController: UIViewController {
    @IBOutlet weak var gameLoadingBar: GameLoadingBar!
    private let barAnimationDuration = 0.1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set the count items for the gameLoadingBar
        gameLoadingBar.totalItems = 9
        gameLoadingBar.animationDuration = barAnimationDuration
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performLoading()
    }
    
    private func performLoading() {
        // create a dispatch group so we can wait for it
        let dispatchGroup = DispatchGroup()
        
        // dispatch it off the main queue so that the loading bar can animate
        DispatchQueue.global(qos: .userInteractive).async(group: dispatchGroup) { [weak self] in
            let realm = try! Realm()
            
            self?.setAllowances(withRealm: realm)
            self?.gameLoadingBar.completedItems += 1
            
            self?.setPlayerProgress(withRealm: realm)
            self?.gameLoadingBar.completedItems += 1
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            DebugUtil.print("Loading is complete. Delayed dispatch back to main queue before segueing")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self?.performSegue(withIdentifier: "fadeToMainMenu", sender: nil)
            }
        }
    }
    
    private func setAllowances(withRealm realm: Realm) {
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
    }
    
    private func setPlayerProgress(withRealm realm: Realm) {
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
    }
}
