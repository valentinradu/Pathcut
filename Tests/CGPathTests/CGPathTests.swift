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

    func testSplines() throws {
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

    static var allTests = [
        ("testCrossings", testDataPath),
        ("testElements", testSplines),
    ]
}
