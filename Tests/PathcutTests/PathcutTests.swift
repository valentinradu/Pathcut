import XCTest
@testable import Pathcut

final class PathcutTests: XCTestCase {
    func testCrossings() throws {
        let data = try TestData.load(name: "simple")
        guard let firstData = data.paths.first else {fatalError()}
        guard let secondData = data.paths.last else {fatalError()}

        let firstPath = CGMutablePath()
        try firstPath.addPath(data: firstData)

        let secondPath = CGMutablePath()
        try secondPath.addPath(data: secondData)

        let intersections = firstPath.intersections(with: secondPath)
        XCTAssertEqual(intersections.count, 2)
    }

    func testDataPath() throws {
        let data = try TestData.load(name: "simple")
        guard let pathData = data.paths.first else {fatalError()}
        let path = CGMutablePath()
        try path.addPath(data: pathData)

        XCTAssertEqual(path.data, pathData)
    }

    static var allTests = [
        ("testCrossings", testCrossings),
    ]
}
