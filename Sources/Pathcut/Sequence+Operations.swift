//
//  Sequence+Operations.swift
//  Cadenza
//
//  Created by Valentin Radu on 30/09/2019.
//  Copyright © 2019 Codewise Systems. All rights reserved.
//

import Foundation

extension Sequence {
    func group(_ maxGroupSize: Int) -> [[Element]] {
        reduce([[Element]]()) { (subdivs, subdiv) in
            var columns = subdivs
            var row = columns.popLast() ?? []
            if row.count < maxGroupSize {
                row.append(subdiv)
                columns.append(row)
            }
            else {
                columns.append(contentsOf: [row, [subdiv]])
            }
            return columns
        }
    }
}
