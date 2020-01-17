//
//  File.swift
//  
//
//  Created by Valentin Radu on 16/01/2020.
//

import Foundation

extension Array {
    mutating func rotate(positions: Int, size: Int? = nil) {
        let size = size ?? count
        guard positions < count && size <= count else { return }

        self[0..<positions].reverse()
        self[positions..<size].reverse()
        self[0..<size].reverse()
    }
    func rotating(positions: Int, size: Int? = nil) -> Self {
        var result = self
        result.rotate(positions: positions, size: size)
        return result
    }
}
