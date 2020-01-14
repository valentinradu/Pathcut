//
//  File.swift
//  
//
//  Created by Valentin Radu on 13/01/2020.
//

import Foundation

private let places: Int = 6
private let maxIters: Int = 500

public struct CGSplitPoint {
    let point: CGPoint
    let control1: CGPoint
    let control2: CGPoint
}

public struct CGSpline {
    enum Kind {
        case line
        case quad
        case curve
    }

    let points: [CGPoint]
    let kind: Kind
    init(kind: Kind, points: [CGPoint]) {
        self.kind = kind
        self.points = points
    }

    func intersections(with spline: CGSpline) -> [CGSplitPoint] {
            if kind == .line && spline.kind == .line {

            }

            func hasConverged(range: Range<Double>) -> Bool {
                let factor = pow(10.0, Double(places))
                return Int(range.lowerBound * factor) == Int(range.upperBound * factor)
            }

            while hasConverged(range: 0..<1) {

            }
            return []
        }
}

public extension CGPath {

    var splines: [CGSpline] {
        var origin: CGPoint = .zero
        var prev: CGPoint = .zero
        var result: [CGSpline] = []
        applyWithBlock {
            let elem = $0.pointee
            var elemPointsCount: Int? = nil
            var splineKind: CGSpline.Kind? = nil
            switch elem.type {
            case .moveToPoint:
                origin = elem.points[0]
                prev = origin
            case .addLineToPoint:
                elemPointsCount = 1
                splineKind = .line
            case .addQuadCurveToPoint:
                elemPointsCount = 2
                splineKind = .quad
            case .addCurveToPoint:
                elemPointsCount = 3
                splineKind = .curve
            case .closeSubpath:
                let spline = CGSpline(kind: .line, points: [prev, origin])
                result.append(spline)
                prev = origin
            @unknown default:
                break
            }

            if let kind = splineKind, let count = elemPointsCount {
                let points = Array(UnsafeBufferPointer(start: elem.points, count: count))
                let spline = CGSpline(kind: kind, points: [prev] + points)
                result.append(spline)
            }

            if let count = elemPointsCount {
                prev = elem.points[count - 1]
            }
        }
        return result
    }

    func intersections(with otherPath: CGPath) -> [CGSplitPoint] {
        return intersections(with: otherPath.splines)
    }

    func intersections(with otherSplines: [CGSpline]) -> [CGSplitPoint] {
        var result: [CGSplitPoint] = []
        for spline in splines {
            for otherSpline in otherSplines {
                result.append(contentsOf: spline.intersections(with: otherSpline))
            }
        }
        return result
    }
}
