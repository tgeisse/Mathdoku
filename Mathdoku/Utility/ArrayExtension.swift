//
//  ArrayExtension.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/29/20.
//  Copyright © 2020 Taylor Geisse. All rights reserved.
//

import Foundation

extension Array {
    func safeValue(at index: Int) -> Element? {
        if index < self.count {
            return self[index]
        } else {
            return nil
        }
    }
}
