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
    private let colorThemes = ColorTheme.Themes.allCases.map { ColorTheme(theme: $0) }

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
        ColorTheme.sharedInstance.updateTheme(colorThemes[indexPath.item].theme)
        if #available(iOS 13.0, *) {
            navigationController?.topViewController?.navigationController?.overrideUserInterfaceStyle = [ColorTheme.Themes.darkMode, .midnight].contains(ColorTheme.sharedInstance.theme) ? .dark : .light
            navigationController?.topViewController?.navigationController?.navigationBar.overrideUserInterfaceStyle = [ColorTheme.Themes.darkMode, .midnight].contains(ColorTheme.sharedInstance.theme) ? .dark : .light
        }
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
        // set the main color theme for the table row
        cell.themeTitle.text = "\(theme.theme)"
        cell.themeTitle.textColor = theme.fonts
        cell.backgroundColor = theme.background
        
        // set the color theme for all of the cells
        cell.allCells.forEach {
            $0.colorTheme = theme
            $0.cell.colorTheme = theme
        }
        
        // leftmost cell
        cell.cell1.currentHighlightState = .friendly
        let leftCell = cell.cell1.cell
        leftCell.rightBorder = .friend
        leftCell.hint = "8+"
        leftCell.guess = "2"
        leftCell.addGuessAllegiance(.conflict)
        
        // center left cell
        cell.cell2.currentHighlightState = .friendly
        let centerLeftCell = cell.cell2.cell
        centerLeftCell.leftBorder = .friend
        centerLeftCell.rightBorder = .friend
        centerLeftCell.note = "1  4"
        
        // center right cell
        cell.cell3.currentHighlightState = .selected
        let centerRightCell = cell.cell3.cell
        centerRightCell.leftBorder = .friend
        centerRightCell.rightBorder = .foe
        centerRightCell.guess = "3"
        centerRightCell.addGuessAllegiance(.equal)
        
        // rightmost cell
        let rightCell = cell.cell4.cell
        rightCell.leftBorder = .foe
        rightCell.hint = "2"
        rightCell.guess = "2"
        rightCell.addGuessAllegiance(.conflict)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CellViewElementValues.sharedInstance.clear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        CellViewElementValues.sharedInstance.clear()
    }
    
    @IBAction func testItemButton(_ sender: UIBarButtonItem) {
        guard let cells = tableView.visibleCells as? [ColorThemePreviewTableViewCell] else { return }
        
        cells.forEach { cell in
            cell.cell2.cell.guess = "2"
        }
    }
    
}
