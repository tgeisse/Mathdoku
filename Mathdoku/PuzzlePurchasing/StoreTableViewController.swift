//
//  StoreTableViewController.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 12/26/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit

class StoreTableViewController: UITableViewController {
    
    private func loadProductInfo(forCell cell: StoreTableViewCell, forProduct: PuzzleProduct) {
        cell.addActivityIndicator()
        
        DispatchQueue.global(qos: .userInitiated).async {
            let processRetrievedProduct = {(cell: StoreTableViewCell, product: SKProduct) in
                
                DebugUtil.print("Retrieved product info. Displaying it to the cell - \(product.localizedTitle)")
                
                DispatchQueue.main.async {
                    PuzzleProducts.setLoadedPuzzleProduct(product, forIdentifier: forProduct.productIdentifier)
                    cell.product = product
                    cell.puzzleProduct = forProduct
                    cell.removeActivityIndicator()
                    cell.updateBuyButton()
                }
            }
            
            if let prod = PuzzleProducts.getLoadedPuzzleProduct(forIdentifier: forProduct.productIdentifier) {
                DebugUtil.print("Product already loaded")
                processRetrievedProduct(cell, prod)
            } else {
                DebugUtil.print("Product needs to be loaded from the store")
                SwiftyStoreKit.retrieveProductsInfo([forProduct.productIdentifier]) { results in
                    
                    if let prod = results.retrievedProducts.first {
                        processRetrievedProduct(cell, prod)
                    }
                    for invalidProductId in results.invalidProductIDs {
                        DebugUtil.print("Could not retrieve product info. Invalid product identifier: \(invalidProductId)")
                    }
                    if let error = results.error {
                        DebugUtil.print("Error: \(error)")
                    }
                }
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return PuzzleProducts.PuzzlePacks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "storePuzzlePack", for: indexPath) as? StoreTableViewCell else {
            fatalError("A cell that is not a store puzzle pack made it into the queue")
        }

        // Configure the cell...
        let product = PuzzleProducts.PuzzlePacks[indexPath.item]
        cell.promotionalImage.image = product.promotionalImage
        cell.titleText.text = product.title
        cell.descriptionText.text = product.description
        
        loadProductInfo(forCell: cell, forProduct: product)

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
