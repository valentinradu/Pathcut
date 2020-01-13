import QuartzCore

public enum Errors: Error {
    case invalidPointData
    case invalidPathData
    case invalidPathCommand
    case unsupportedPathCommand(String)
}

public struct CGCurvePoint {
    let point: CGPoint
    let control1: CGPoint
    let control2: CGPoint
}

public extension CGPoint {
    init(data: String) throws {
        let values = data.components(separatedBy: ",")
            .compactMap({Double($0)})
            .map({CGFloat($0)})
        guard let x = values[safe: 0] else {throw Errors.invalidPointData}
        guard let y = values[safe: 1] else {throw Errors.invalidPointData}
        self.init(x: x, y: y)
    }
    var data: String {
        return "\(x),\(y)"
    }
}

public extension CGMutablePath {
    var data: String {
        var result:[String] = []
        self.applyWithBlock {
            let elem = $0.pointee
            switch elem.type {
            case .moveToPoint:
                result.append("M\(elem.points[0].data)")
            case .addLineToPoint:
                result.append("L\(elem.points[0].data)")
            case .addQuadCurveToPoint:
                result.append("Q\(elem.points[0].data) \(elem.points[1].data)")
            case .addCurveToPoint:
                result.append("C\(elem.points[0].data) \(elem.points[1].data) \(elem.points[2].data)")
            case .closeSubpath:
                result.append("Z")
            @unknown default:
                break
            }
        }
        return result.joined(separator: " ")
    }

    func addPath(data: String) throws {
        guard data.count > 0 else {return}

        func consume(commands: [String]) throws -> ([CGPoint], [String]) {
            let remaining = commands.dropFirst()
            let tail = Array(remaining.drop(while: {$0.first?.isLetter == false}))
            let head = try remaining.dropLast(tail.count).map({try CGPoint(data: $0)})
            return (head, tail)
        }

        var commands = data
            .components(separatedBy: " ")
            .reduce([String](), { a, r in
                guard let first = r.first else {return a}
                let s: [String]
                if first.isLetter == true {
                    s = [String(first), String(r.dropFirst())]
                }
                else {
                    s = [r]
                }
                return a + s
            })

        var lastPoint: CGPoint = .zero
        while commands.count != 0 {
            guard let first = commands.first?.first else {throw Errors.invalidPathData}
            var (points, rest) = try consume(commands: commands)
            if first.isLowercase {
                let transform: CGAffineTransform = .init(translationX: lastPoint.x, y: lastPoint.y)
                points = points.map({$0.applying(transform)})
            }
            switch first.uppercased() {
            case "M":
                let point = points[points.count - 1]
                move(to: point)
            case "Z":
                closeSubpath()
                return
            case "L":
                for point in points {
                    addLine(to: point)
                }
            case "C":
                for controls in points.group(3) {
                    addCurve(to: controls[2], control1: controls[0], control2: controls[1])
                }
            case "Q":
                for controls in points.group(2) {
                    addQuadCurve(to: controls[1], control: controls[0])
                }
            default:
                if first.isLetter {
                    throw Errors.unsupportedPathCommand(String(first))
                }
                else {
                    throw Errors.invalidPathCommand
                }
            }
            commands = rest

            if first.uppercased() != "Z" {
                lastPoint = points[points.count - 1]
            }
        }
    }
}

public extension CGMutablePath {
    func intersections(with: CGPath) -> [CGCurvePoint] {
       return []
    }
}
