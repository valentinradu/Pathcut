import XCTest
@testable import Pathcut

final class CGPathTests: XCTestCase {
    func testDataPath() throws {
        let data = try TestData.load(name: "simple")
        guard let pathData = data.paths.first else {fatalError()}
        let path = CGMutablePath()
        try path.addPath(data: pathData)

        XCTAssertEqual(path.data, pathData)
    }

    func testSplinesCreate() throws {
        let path = CGMutablePath()
        try path.addPath(data: "M0,0 M3,2 L1,1 L1,0 C0.5,0.5 0.5,0.5 0,0 Z")
        XCTAssertEqual(
            path.splines.map({$0.kind}),
            [CGSpline.Kind.segment, .segment, .curve, .segment]
        )
        XCTAssertEqual(
            path.splines.map({$0.points.map({[$0.x, $0.y]})}),
            [
                [[3, 2], [1, 1]],
                [[1, 1], [1, 0]],
                [[1, 0], [0.5, 0.5], [0.5, 0.5], [0, 0]],
                [[0, 0], [3, 2]]
            ]
        )
    }

    func testSplinesCollinearity()  {
        let segment = CGSpline(kind: .segment, points: [.init(x: 1, y: 1), .init(x: 5, y: 3)])
        XCTAssertEqual(segment.collinearity, CGSpline.Collinearity(kind: .slope, m: 0.5, b: 0.5))

        let pointLine = CGSpline(kind: .segment, points: [.init(x: 0, y: 0), .init(x: 0, y: 0)])
        XCTAssertEqual(pointLine.collinearity, CGSpline.Collinearity(kind: .point))

        let pointCurve = CGSpline(kind: .curve, points: [
            .init(x: 0, y: 0),
            .init(x: 0, y: 0),
            .init(x: 0, y: 0),
            .init(x: 0, y: 0)
        ])
        XCTAssertEqual(pointCurve.collinearity, CGSpline.Collinearity(kind: .point))

        let vertical = CGSpline(kind: .segment, points: [.init(x: 1, y: 5), .init(x: 1, y: 0)])
        XCTAssertEqual(vertical.collinearity, CGSpline.Collinearity(kind: .vertical))

        let horizontal = CGSpline(kind: .segment, points: [.init(x: 5, y: 1), .init(x: 2, y: 1)])
        XCTAssertEqual(horizontal.collinearity, CGSpline.Collinearity(kind: .horizontal))

        let curve = CGSpline(kind: .curve, points: [
            .init(x: 0, y: 0.5),
            .init(x: 1, y: 1),
            .init(x: 5, y: 3),
            .init(x: 6, y: 3.5),
        ])
        XCTAssertEqual(curve.collinearity, CGSpline.Collinearity(kind: .slope, m: 0.5, b: 0.5))
    }

    func testSplinesSimpleIntersection() {
        let slope = CGSpline(kind: .segment, points: [.init(x: 0, y: 0), .init(x: 6, y: 3)])
        let vertical = CGSpline(kind: .segment, points: [.init(x: 4, y: 0), .init(x: 4, y: 4)])
        let horizontal = CGSpline(kind: .segment, points: [.init(x: 0, y: 2), .init(x: 6, y: 2)])
        let point = CGSpline(kind: .segment, points: [.init(x: 0, y: 0), .init(x: 0, y: 0)])
        let curve = CGSpline(kind: .curve, points: [
            .init(x: 2, y: 4),
            .init(x: 3, y: 3),
            .init(x: 5, y: 1),
            .init(x: 6, y: 0)
        ])
        let outside = CGSpline(kind: .segment, points: [.init(x: 0, y: 2), .init(x: 2, y: 2)])
        let intersectionPoint = CGPoint(x: 4, y: 2)

        func splitAt(_ spline: CGSpline, _ point: CGPoint) -> [CGSpline] {
            return [
                CGSpline(kind: .segment, points: [spline.points[0], point]),
                CGSpline(kind: .segment, points: [point, spline.points[spline.points.count - 1]])
            ]
        }

        XCTAssertEqual(slope.intersections(with: point), [])
        XCTAssertEqual(slope.intersections(with: vertical), splitAt(slope, intersectionPoint))
        XCTAssertEqual(slope.intersections(with: horizontal), splitAt(slope, intersectionPoint))
        XCTAssertEqual(slope.intersections(with: slope), [])
        XCTAssertEqual(slope.intersections(with: curve), splitAt(slope, intersectionPoint))
        XCTAssertEqual(slope.intersections(with: outside), [])
        XCTAssertEqual(curve.intersections(with: horizontal), splitAt(curve, intersectionPoint))
    }

    func testSplinesSplit() {
        let curve = CGSpline(kind: .curve, points: [
            .init(x: 0, y: 0),
            .init(x: 4, y: 2),
            .init(x: 4, y: 6),
            .init(x: 0, y: 8)
        ])
        if let result = curve.split(at: 0.5) {
            let firstPoints: [CGPoint] = [
                .init(x: 0, y: 0),
                .init(x: 2, y: 1),
                .init(x: 3, y: 2.5),
                .init(x: 3, y: 4)
            ]
            let lastPoints: [CGPoint] = [
                .init(x: 3, y: 4),
                .init(x: 3, y: 5.5),
                .init(x: 2, y: 7),
                .init(x: 0, y: 8)
            ]

            XCTAssertEqual(result.0, CGSpline(kind: .curve, points: firstPoints))
            XCTAssertEqual(result.1, CGSpline(kind: .curve, points: lastPoints))
        }
        else {
            XCTFail()
        }
    }

    func testSplinesSplitFail() {
        let point = CGSpline(kind: .segment, points: [.init(x: 0, y: 0), .init(x: 0, y: 0)])
        XCTAssertNil(point.split(at: 0.5))
    }

    func testSegment() {
        let segment = CGLine(start: .zero, end: CGPoint(x: 4, y: 4))
        let outer = CGPoint(x: -3, y: 1)
        let upper = CGPoint(x: 3, y: 4)
        let inner = CGPoint(x: 3, y: 1)
        XCTAssertEqual(segment.distance(to: outer), 2.83, accuracy: 0.01)
        XCTAssertEqual(segment.distance(to: upper), 0.70, accuracy: 0.01)
        XCTAssertEqual(segment.distance(to: inner), -1.41, accuracy: 0.01)
    }

    func testFatline() {
        let spline = CGSpline(kind: .curve, points: [
            .init(x: 0, y: 0),
            .init(x: 4, y: 0),
            .init(x: 3, y: 4),
            .init(x: 4, y: 4)
        ])
        if let (line, minimum, maximum) = spline.fatLine() {
            XCTAssertEqual(line, CGLine(start: .zero, end: .init(x: 4, y: 4)))
            XCTAssertEqual(maximum, 0.70, accuracy: 0.01)
            XCTAssertEqual(minimum, -2.82, accuracy: 0.01)
        }
        else {
            XCTFail()
        }
    }

    func testFatlineConvex() {
        let spline = CGSpline(kind: .curve, points: [
            .init(x: 0, y: 0),
            .init(x: 4, y: 0),
            .init(x: 4, y: 3),
            .init(x: 4, y: 4)
        ])
        if let (_, minimum, maximum) = spline.fatLine() {
            XCTAssertEqual(maximum, 0)
            XCTAssertEqual(minimum, -2.82, accuracy: 0.01)
        }
        else {
            XCTFail()
        }
    }

    func testClip() {
        let spline = CGSpline(kind: .curve, points: [
            .init(x: 0, y: 0),
            .init(x: 3.75, y: 0),
            .init(x: 1, y: 4),
            .init(x: 4, y: 4)
        ])
        let line = CGLine(start: .init(x: 0, y: 2), end: .init(x: 4, y: 2))
        if let result = spline.clip(around: line, minimum: -1, maximum: 1.5) {
            let startPoint = result.points[0]
            let endPoint = result.points[result.points.count - 1]
            XCTAssertEqual(startPoint.x, 2, accuracy: 0.01)
            XCTAssertEqual(startPoint.y, 1, accuracy: 0.01)
            XCTAssertEqual(endPoint.x, 2.7, accuracy: 0.01)
            XCTAssertEqual(endPoint.y, 3.5, accuracy: 0.01)
        }
        else {
            XCTFail()
        }
    }

    static var allTests = [
        ("testDataPath", testDataPath),
        ("testSplinesCreate", testSplinesCreate),
    ]
}
