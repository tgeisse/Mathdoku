//
//  StoreTableViewController.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 12/26/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit
import StoreKit

class StoreTableViewController: UITableViewController {    
    // MARK: - Product information loading
    func loadAllProducts() {
        DispatchQueue.global(qos: .userInitiated).async {
            var pIdsNeedingToBeFetched = [String]()
            var loadedPuzzleIndexSet = [IndexPath]()
            
            for (id, puzzle) in PuzzleProducts.PuzzlePacks.enumerated() {
                if let _ = PuzzleProducts.getLoadedPuzzleProduct(forIdentifier: puzzle.productIdentifier) {
                    loadedPuzzleIndexSet.append(IndexPath(row: id, section: 0))
                } else {
                    pIdsNeedingToBeFetched.append(puzzle.productIdentifier)
                }
            }
            
            if loadedPuzzleIndexSet.count > 0 {
                // simply reload the table rows - will see if I need this
                DebugUtil.print("\(loadedPuzzleIndexSet.count) puzzle product informations were already loaded")
            }
            
            if pIdsNeedingToBeFetched.count > 0 {
                DebugUtil.print("Need to load puzzle details for the following products: \(pIdsNeedingToBeFetched)")
                StoreKitWrapper.sharedInstance.requestProductInfo(forProducts: pIdsNeedingToBeFetched) { [weak self] (success, products) in
                    
                    guard let products = products else { return }
                    
                    var pIdSet = Set<String>()
                    
                    for product in products {
                        pIdSet.insert(product.productIdentifier)
                        PuzzleProducts.setLoadedPuzzleProduct(product, forIdentifier: product.productIdentifier)
                    }
                    
                    let reloadRows = PuzzleProducts.PuzzlePacks.enumerated().filter {
                        pIdSet.contains($0.element.productIdentifier)
                    }.map { IndexPath(row: $0.offset, section: 0) }
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.tableView.performBatchUpdates() { [weak self] in
                            self?.tableView.reloadRows(at: reloadRows, with: .automatic)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        CrashWrapper.leaveBreadcrumb(withMessage: "Entered StoreTableViewController")
        loadAllProducts()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        CrashWrapper.leaveBreadcrumb(withMessage: "Left StoreTableViewController")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PuzzleProducts.PuzzlePacks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "storePuzzlePack", for: indexPath) as? StoreTableViewCell else {
            CrashWrapper.notifyException(name: .cast, reason: "Dequeued incorrect type (StoreTableViewCell)")
            fatalError("A cell that is not a store puzzle pack made it into the queue")
        }

        // Configure the cell...
        let product = PuzzleProducts.PuzzlePacks[indexPath.item]
        cell.promotionalImage.image = product.promotionalImage
        cell.titleText.text = product.title
        cell.descriptionText.text = product.description
        cell.puzzleProduct = product
        cell.product = PuzzleProducts.getLoadedPuzzleProduct(forIdentifier: product.productIdentifier)

        return cell
    }
}
