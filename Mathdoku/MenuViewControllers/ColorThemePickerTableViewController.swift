//
//  ColorThemePickerTableViewController.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 12/8/20.
//  Copyright © 2020 Taylor Geisse. All rights reserved.
//

import UIKit

class ColorThemePickerTableViewController: UITableViewController {

    // MARK: - Table view data source
    private var colorThemes = [ColorTheme]()
    
    private func updateAvailableThemes() {
        colorThemes = [ColorTheme]()
        
        for theme in ColorTheme.Themes.allCases {
            colorThemes.append(ColorTheme(theme: theme))
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return colorThemes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "colorThemePreview", for: indexPath) as? ColorThemePreviewTableViewCell else {
            CrashWrapper.notifyException(name: .cast, reason: "Dequeued incorrect type (ColorThemePreviewTableViewCell)")
            fatalError("A cell that is not a color theme preview cell made it into the queue")
        }

        // Configure the cell...
        setScene(forCell: cell, forTheme: colorThemes[indexPath.item])

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ColorTheme.sharedInstance.updateTheme(byInt: indexPath.item)
        navigationController?.popViewController(animated: true)
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
    
    private func setScene(forCell cell: ColorThemePreviewTableViewCell, forTheme theme: ColorTheme) {
        cell.themeTitle.text = "\(theme.theme)"
    }

    // MARK: - Navigation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateAvailableThemes()
    }
}
