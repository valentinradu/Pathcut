//
//  File.swift
//  
//
//  Created by Valentin Radu on 13/01/2020.
//

import Foundation

private let places: Int = 6
private let maxIters: Int = 500

public struct CGSplitPoint: Equatable {
    enum Kind {
        case simple
        case bezier
    }
    let kind: Kind
    let points: [CGPoint]
}

public struct CGSpline {
    enum Kind: Int {
        case line
        case quad
        case curve
    }

    struct Collinearity: Equatable {
        enum Kind: Int {
            case point
            case horizontal
            case vertical
            case slope
            case curve
        }
        let kind: Kind
        let m: Double
        let b: Double
        init(kind: Kind, m: Double = 0, b: Double = 0) {
            self.kind = kind
            self.m = m
            self.b = b
        }
    }

    let points: [CGPoint]
    let kind: Kind
    let collinearity: Collinearity
    init(kind: Kind, points: [CGPoint]) {
        let count: Int
        switch kind {
        case .line:
            count = 2
        case .quad:
            count = 3
        case .curve:
            count = 4
        }
        assert(points.count == count)
        assert(points.count > 0)

        self.kind = kind
        self.points = Array(points.prefix(count))

        if points.count < 2 {
            self.collinearity = Collinearity(kind: .point)
        }
        else if points[0].x == points[1].x || points[0].y == points[1].y {
            let horizontal = points.reduce(true, {$0 && $1.y == points[0].y})
            let vertical = points.reduce(true, {$0 && $1.x == points[0].x})
            if horizontal && vertical {
                self.collinearity = Collinearity(kind: .point)
            }
            else if horizontal {
                self.collinearity = Collinearity(kind: .horizontal)
            }
            else {
                self.collinearity = Collinearity(kind: .vertical)
            }
        }
        else {
            let m = Double((points[0].y - points[1].y)/(points[0].x - points[1].x))
            let b = Double(points[0].y) - m * Double(points[0].x)
            let factor = pow(10.0, Double(places))
            for point in points {
                if Int(Double(point.y) * factor) != Int((m * Double(point.x) + b) * factor) {
                    self.collinearity = Collinearity(kind: .curve)
                    return
                }
            }
            self.collinearity = Collinearity(kind: .slope, m: m, b: b)
        }
    }

    func intersections(with spline: CGSpline) -> [CGSplitPoint] {
        if points.count < 2 || spline.points.count < 2 {
            return []
        }

        let group = [self, spline].sorted(by: {$0.kind.rawValue < $1.kind.rawValue})

        if (group[0].collinearity.kind == .point)
            || (group[0].collinearity.kind == .horizontal && group[1].collinearity.kind == .horizontal)
            || (group[0].collinearity.kind == .vertical && group[1].collinearity.kind == .vertical) {
            return []
        }
        else {
            var intersectionPoint: CGPoint? = nil
            if (group[0].collinearity.kind == .horizontal && group[1].collinearity.kind == .vertical) {
                intersectionPoint = CGPoint(x: group[1].points[0].x, y: group[0].points[0].y)
            }
            else if (group[0].collinearity.kind == .horizontal && group[1].collinearity.kind == .slope) {
                let y = Double(group[0].points[0].y)
                let c = group[1].collinearity
                let x = (y - c.b)/c.m
                intersectionPoint = CGPoint(x: x, y: y)
            }
            else if (group[0].collinearity.kind == .horizontal && group[1].collinearity.kind == .curve) {
                intersectionPoint = .zero //TODO
            }
            else if (group[0].collinearity.kind == .vertical && group[1].collinearity.kind == .slope) {
                let x = Double(group[0].points[0].x)
                let c = group[1].collinearity
                let y = x * c.m + c.b
                intersectionPoint = CGPoint(x: x, y: y)
            }
            else if (group[0].collinearity.kind == .vertical && group[1].collinearity.kind == .curve) {
                intersectionPoint = .zero //TODO
            }
            else if (collinearity.kind == .slope || spline.collinearity.kind == .slope) {
                let c = collinearity
                let oc = spline.collinearity
                let x = (oc.b - c.b)/(c.m - oc.m)
                let y = x * c.m + c.b
                intersectionPoint = CGPoint(x: x, y: y)
            }

            if let intersectionPoint = intersectionPoint {
                let ad = points[0].distanceTo(intersectionPoint)
                let bd = points[0].distanceTo(points[1])
                let cd = points[1].distanceTo(intersectionPoint)

                if pow(ad, 2) + pow(bd, 2) >= pow(cd, 2) && pow(ad, 2) + pow(cd, 2) >= pow(bd, 2) {
                    return [CGSplitPoint(kind: .simple, points: [intersectionPoint])]
                }
                else {
                    return []
                }
            }
            else {
                func hasConverged(range: Range<Double>) -> Bool {
                    let factor = pow(10.0, Double(places))
                    return Int(range.lowerBound * factor) == Int(range.upperBound * factor)
                }

                while hasConverged(range: 0..<1) {

                }
                return []
            }
        }
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
