//
//  StatsViewController.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/7/20.
//  Copyright © 2020 Taylor Geisse. All rights reserved.
//

import UIKit

@IBDesignable
class StatsGraphViewController: UIViewController {
    @IBOutlet weak var barChartview: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DebugUtil.print("")
        
        barChartview.processDataSet(solvedPuzzles: [Double](repeating: 10.0, count: 20))
    }
}
