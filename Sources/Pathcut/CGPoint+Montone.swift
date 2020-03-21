//  
//
//  Created by Valentin Radu on 16/01/2020.
//

import Foundation
import CoreGraphics


public func cross(_ o: CGPoint, _ a: CGPoint, _ b: CGPoint) -> CGFloat {
    let lhs = (a.x - o.x) * (b.y - o.y)
    let rhs = (a.y - o.y) * (b.x - o.x)
    return lhs - rhs
}

/// Calculate and return the convex hull of a given sequence of points.
///
/// - Remark: Implements Andrew’s monotone chain convex hull algorithm.
///
/// - Complexity: O(*n* log *n*), where *n* is the count of `points`.
///
/// - Parameter points: A sequence of `CGPoint` elements.
///
/// - Returns: An array containing the convex hull of `points`, ordered
///   lexicographically from the smallest coordinates to the largest,
///   turning counterclockwise.
///
public func convexHull<Source>(of points: Source) -> [CGPoint] where Source : Collection, Source.Element == CGPoint
{
    // Exit early if there aren’t enough points to work with.
    guard points.count > 1 else { return Array(points) }

    // Create storage for the lower and upper hulls.
    var lower = [CGPoint]()
    var upper = [CGPoint]()

    // Sort points in lexicographical order.
    let points = points.sorted { a, b in
        a.x < b.x || a.x == b.x && a.y < b.y
    }

    // Construct the lower hull.
    for point in points {
        while lower.count >= 2 {
            let a = lower[lower.count - 2]
            let b = lower[lower.count - 1]
            if cross(a, b, point) > 0 { break }
            lower.removeLast()
        }
        lower.append(point)
    }

    // Construct the upper hull.
    for point in points.lazy.reversed() {
        while upper.count >= 2 {
            let a = upper[upper.count - 2]
            let b = upper[upper.count - 1]
            if cross(a, b, point) > 0 { break }
            upper.removeLast()
        }
        upper.append(point)
    }

    // Remove each array’s last point, as it’s the same as the first point
    // in the opposite array, respectively.
    lower.removeLast()
    upper.removeLast()

    // Join the arrays to form the convex hull.
    return lower + upper
}
