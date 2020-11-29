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
}
