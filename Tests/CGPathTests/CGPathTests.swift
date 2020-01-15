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
            [CGSpline.Kind.line, .line, .curve, .line]
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
        let line = CGSpline(kind: .line, points: [.init(x: 1, y: 1), .init(x: 5, y: 3)])
        XCTAssertEqual(line.collinearity, CGSpline.Collinearity(kind: .slope, m: 0.5, b: 0.5))

        let pointLine = CGSpline(kind: .line, points: [.init(x: 0, y: 0), .init(x: 0, y: 0)])
        XCTAssertEqual(pointLine.collinearity, CGSpline.Collinearity(kind: .point))

        let pointCurve = CGSpline(kind: .curve, points: [
            .init(x: 0, y: 0),
            .init(x: 0, y: 0),
            .init(x: 0, y: 0),
            .init(x: 0, y: 0)
        ])
        XCTAssertEqual(pointCurve.collinearity, CGSpline.Collinearity(kind: .point))

        let vertical = CGSpline(kind: .line, points: [.init(x: 1, y: 5), .init(x: 1, y: 0)])
        XCTAssertEqual(vertical.collinearity, CGSpline.Collinearity(kind: .vertical))

        let horizontal = CGSpline(kind: .line, points: [.init(x: 5, y: 1), .init(x: 2, y: 1)])
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
        let slope = CGSpline(kind: .line, points: [.init(x: 0, y: 0), .init(x: 6, y: 3)])
        let vertical = CGSpline(kind: .line, points: [.init(x: 4, y: 0), .init(x: 4, y: 4)])
        let horizontal = CGSpline(kind: .line, points: [.init(x: 0, y: 2), .init(x: 6, y: 2)])
        let point = CGSpline(kind: .line, points: [.init(x: 0, y: 0), .init(x: 0, y: 0)])
        let curve = CGSpline(kind: .curve, points: [
            .init(x: 2, y: 4),
            .init(x: 3, y: 3),
            .init(x: 5, y: 1),
            .init(x: 6, y: 0)
        ])
        let outside = CGSpline(kind: .line, points: [.init(x: 0, y: 2), .init(x: 2, y: 2)])
        let intersectionPoint = CGSplitPoint(kind: .simple, points: [CGPoint(x: 4, y: 2)])

        XCTAssertEqual(slope.intersections(with: point), [])
        XCTAssertEqual(slope.intersections(with: vertical), [intersectionPoint])
        XCTAssertEqual(slope.intersections(with: horizontal), [intersectionPoint])
        XCTAssertEqual(slope.intersections(with: slope), [])
        XCTAssertEqual(slope.intersections(with: curve), [])
        XCTAssertEqual(slope.intersections(with: outside), [])
        XCTAssertEqual(curve.intersections(with: horizontal), [intersectionPoint])
    }

    static var allTests = [
        ("testDataPath", testDataPath),
        ("testSplinesCreate", testSplinesCreate),
    ]
}
