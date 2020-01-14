//
//  File.swift
//  
//
//  Created by Valentin Radu on 13/01/2020.
//

import Foundation


public struct CGSplitPoint {
    let point: CGPoint
    let control1: CGPoint
    let control2: CGPoint
}

public extension CGPath {

    var elements: [CGPathElement] {
        var result: [CGPathElement] = []
        applyWithBlock {result.append($0.pointee)}
        return result
    }

    func intersectionsBetween(_ element: CGPathElement, and otherElement: CGPathElement) -> [CGSplitPoint] {
        
        return []
    }

    func intersections(with path: CGPath) -> [CGSplitPoint] {
        var result: [CGSplitPoint] = []
        for elem in elements {
            for otherElem in path.elements {
                result.append(contentsOf: intersectionsBetween(elem, and: otherElem))
            }
        }

        return result
    }
}
