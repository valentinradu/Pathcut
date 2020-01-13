//
//  Collection+SafeAccess.swift
//  Cadenza
//
//  Created by Valentin Radu on 11/12/2019.
//  Copyright © 2019 Codewise Systems SRL. All rights reserved.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
