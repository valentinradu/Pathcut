//
//  File.swift
//
//
//  Created by Valentin Radu on 24/11/2019.
//

import Foundation
import QuartzCore
import AppKit

struct TestData: Codable {
    let paths: [String]
}

extension TestData {
    static func load(name: String) throws -> TestData {
        guard let url = Bundle.test.url(forResource: name, withExtension: "json") else {fatalError()}
        let data = try Data.init(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(TestData.self, from: data)
    }
}

public extension Bundle {
    static var test: Bundle {
        let path: [String] = #file
            .split(separator: "/")
            .dropLast(2)
            .map{r in String(r)} + ["Resources"]

        guard let bundle =  Bundle(path: "/" + path.joined(separator: "/")) else {fatalError()}
        return bundle
    }
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

public extension CALayer {
    var bitmapRep: NSBitmapImageRep {
        guard let imageRep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                        pixelsWide: Int(bounds.size.width),
                                        pixelsHigh: Int(bounds.size.height),
                                        bitsPerSample: 8,
                                        samplesPerPixel: 4,
                                        hasAlpha: true,
                                        isPlanar: false,
                                        colorSpaceName: .deviceRGB,
                                        bytesPerRow: 0,
                                        bitsPerPixel: 0) else {fatalError()}


        NSGraphicsContext.saveGraphicsState()
        guard let ctx = NSGraphicsContext(bitmapImageRep: imageRep) else {fatalError()}
        self.render(in: ctx.cgContext)
        NSGraphicsContext.restoreGraphicsState()

        return imageRep
    }
}

public extension Data {
    func write(name: String) throws {
        let url = URL(fileURLWithPath: "\(NSTemporaryDirectory())\(name).png")
        try self.write(to: url)
    }
}

public extension NSBitmapImageRep {
    func save(name: String) throws {
        guard let png = self.representation(using: .png, properties: [:]) else {fatalError()}
        try png.write(name: name)
    }
}

public extension NSImage {
    convenience init(size: CGSize, representation: NSBitmapImageRep) {
        self.init(size: size)
        self.addRepresentation(representation)
    }
    static func load(named: String, ext: String) throws -> NSImage {
        guard let url = Bundle.test.url(forResource: named, withExtension: ext) else {fatalError()}
        let data = try Data.init(contentsOf: url)
        guard let rep = NSBitmapImageRep(data: data) else {fatalError()}
        let image = NSImage(size: rep.size)
        image.addRepresentation(rep)
        return image
    }
    func save(name: String) throws  {
        guard let data = self.tiffRepresentation else {fatalError()}
        guard let rep = NSBitmapImageRep(data: data) else {fatalError()}
        try rep.save(name: name)
    }
    private func pixelValues() -> [UInt8]?
    {
        var width = 0
        var height = 0
        var pixelValues: [UInt8]?

        if let imageRef = self.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            width = imageRef.width
            height = imageRef.height
            let bitsPerComponent = imageRef.bitsPerComponent
            let bytesPerRow = imageRef.bytesPerRow
            let totalBytes = height * bytesPerRow
//            let bitmapInfo = imageRef.bitmapInfo // Alpha actually comes last, not premultiplied, see below

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            var intensities = [UInt8](repeating: 0, count: totalBytes)

            let contextRef = CGContext(data: &intensities,
                                      width: width,
                                     height: height,
                           bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                 bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) // alpha last not supported
            contextRef?.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))

            pixelValues = intensities
        }

        return pixelValues
    }

    func compare(similar image: NSImage) -> Double {
        guard let data1 = self.pixelValues(), let data2 = image.pixelValues(), data1.count == data2.count else {
            return Double.greatestFiniteMagnitude
        }

        let width = Double(self.size.width)
        let height = Double(self.size.height)

        return zip(data1, data2)
            .enumerated()
            .reduce(0.0) {
                $1.offset % 4 == 3 ? $0 : $0 + abs(Double($1.element.0) - Double($1.element.1))
            }
            * 100 / (width * height * 3.0) / 255.0
    }
}
