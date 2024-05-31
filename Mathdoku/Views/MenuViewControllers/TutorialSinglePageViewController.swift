//
//  TutorialSinglePageViewController.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 11/29/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit

class TutorialSinglePageViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        AnalyticsWrapper.logEvent(.selectContent, contentType: .presented, id: "id-tutorialPage")
    }
}
