//
//  CGPath+extension.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 11/29/20.
//

import QuartzCore

extension CGPath {
    enum Element {
        case moveToPoint(CGPoint)
        case addLineToPoint(CGPoint)
        case addQuadCurveToPoint(CGPoint, CGPoint)
        case addCurveToPoint(CGPoint, CGPoint, CGPoint)
        case closeSubpath

        init(element: CGPathElement) {
            switch element.type {
            case .moveToPoint: self = .moveToPoint(element.points[0])
            case .addLineToPoint: self = .addLineToPoint(element.points[0])
            case .addQuadCurveToPoint: self = .addQuadCurveToPoint(element.points[0], element.points[1])
            case .addCurveToPoint: self = .addCurveToPoint(element.points[0], element.points[1], element.points[2])
            case .closeSubpath: self = .closeSubpath
            @unknown default:
                fatalError()
            }
        }
        
        var svgPath:String {
            switch(self) {
            case .moveToPoint(let pt):
                //return "M \(pt.x),\(pt.y)"
                return String(format: "M %.2f,%.2f", pt.x, pt.y)
            case .addQuadCurveToPoint(let ct, let pt):
                //return "Q \(ct.x),\(ct.y),\(pt.x),\(pt.y)"
                return String(format: "Q %.2f,%.2f,%.2f,%.2f", ct.x, ct.y, pt.x, pt.y)
            case .addLineToPoint(let pt):
                //return "L \(pt.x),\(pt.y)"
                return String(format: "L %.2f,%.2f", pt.x, pt.y)
            case .addCurveToPoint(let pt, let ct1, let ct2):
                //return "C \(ct1.x),\(ct1.y),\(ct2.x),\(ct2.y),\(pt.x),\(pt.y)"
                return String(format: "C %.2f,%.2f", ct1.x, ct1.y, ct2.x, ct2.y, pt.x, pt.y)
            case .closeSubpath:
                return "Z"
            }
        }
        
        func apply(path:CGMutablePath) -> CGMutablePath {
            switch(self) {
            case .moveToPoint(let pt):
                path.move(to: pt)
            case .addQuadCurveToPoint(let ct, let pt):
                path.addQuadCurve(to: pt, control: ct)
            case .addLineToPoint(let pt):
                path.addLine(to: pt)
            case .addCurveToPoint(let pt, let ct1, let ct2):
                path.addCurve(to: pt, control1: ct1, control2: ct2)
            case .closeSubpath:
                path.closeSubpath()
            }
            return path
        }
    }
    var elements: [CGPath.Element] {
        var pathElements = [CGPath.Element]()
        withUnsafeMutablePointer(to: &pathElements) { elementsPointer in
            apply(info: elementsPointer) { (userInfo, nextElementPointer) in
                let nextElement = CGPath.Element(element: nextElementPointer.pointee)
                let elementsPointer = userInfo!.assumingMemoryBound(to: [CGPath.Element].self)
                elementsPointer.pointee.append(nextElement)
            }
        }
        return pathElements
    }
    var svgPath: String {
        let strs = self.elements.map { element -> String in
            return element.svgPath
        }
        return strs.joined(separator: " ")
    }
}
