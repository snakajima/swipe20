//
//  SwipeElement.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//
import Foundation
import CoreImage
import Cocoa

struct SwipeElement {
    let script:[String:Any]
    let name:String?
    let image:CGImage?
    let path:CGPath?
    
    let frame:CGRect
    let backgroundColor:CGColor?
    let foregroundColor:CGColor?
    let fillColor:CGColor?
    let strokeColor:CGColor?
    let lineWidth:CGFloat?
    let cornerRadius:CGFloat?
    let opacity:CGFloat?
    let anchorPoint:CGPoint?
    let xf:CATransform3D

    let subElementIds:[String]
    let subElements:[String:SwipeElement]

    init(_ script:[String:Any], base:SwipeElement?) {
        self.script = script
        self.name = script["id"] as? String

        let origin = base?.frame.origin ?? CGPoint.zero
        let size = base?.frame.size ?? CGSize(width: 100, height: 100)
        self.frame = CGRect(x: SwipeParser.asCGFloat(script["x"]) ?? origin.x,
                       y: SwipeParser.asCGFloat(script["y"]) ?? origin.y,
                       width: SwipeParser.asCGFloat(script["w"]) ?? size.width,
                       height: SwipeParser.asCGFloat(script["h"]) ?? size.height)

        self.backgroundColor = SwipeParser.parseColor(script["backgroundColor"]) ?? base?.backgroundColor
        self.foregroundColor = SwipeParser.parseColor(script["foregroundColor"]) ?? base?.foregroundColor
        self.fillColor = SwipeParser.parseColor(script["fillColor"]) ?? base?.fillColor
        self.strokeColor = SwipeParser.parseColor(script["strokeColor"]) ?? base?.strokeColor
        self.lineWidth = script["lineWidth"] as? CGFloat ?? base?.lineWidth
        self.cornerRadius = SwipeParser.asCGFloat(script["cornerRadius"]) ?? base?.cornerRadius
        self.opacity = SwipeParser.asCGFloat(script["opacity"]) ?? base?.opacity
        if let points = SwipeParser.asCGFloats(script["anchorPoint"]), points.count == 2 {
            self.anchorPoint = CGPoint(x: points[0], y: points[1])
        } else {
            self.anchorPoint = base?.anchorPoint
        }
        
        var xf = CATransform3DIdentity
        var inheritXf = true
        if let rot = SwipeParser.asCGFloat(script["rotate"]) {
            xf = CATransform3DRotate(xf, rot * CGFloat(CGFloat.pi / 180.0), 0, 0, 1)
            inheritXf = false
        } else if let rots = SwipeParser.asCGFloats(script["rotate"]), rots.count == 3 {
            xf.m34 = -1.0/500; // add the perspective
            let m = CGFloat(CGFloat.pi / 180.0) // LATER: static
            xf = CATransform3DRotate(xf, rots[0] * m, 1, 0, 0)
            xf = CATransform3DRotate(xf, rots[1] * m, 0, 1, 0)
            xf = CATransform3DRotate(xf, rots[2] * m, 0, 0, 1)
            inheritXf = false
        }
        self.xf = inheritXf ? base?.xf ?? xf : xf
        
        if let imageName = script["img"] as? String {
            self.image = NSImage(named: imageName)?.cgImage(forProposedRect: nil, context: nil, hints: nil)
        } else {
            self.image = nil
        }
        //
        // NOTE: In order to eliminate unnecessary computation, we don't inherit path prop
        // from the base element.
        // As the side-effect, the path animation will happen at the different frame in reverse mode.
        //
        self.path = SwipePath.parse(script["path"]) // NOTE: no inheritance

        // nested elements
        let elementScripts = script["elements"] as? [[String:Any]] ?? []
        var ids = [String]()
        var elements:[String:SwipeElement] = base?.subElements ?? [:]
        for elementScript in elementScripts {
            if let id = elementScript["id"] as? String {
                ids.append(id)
                elements[id] = SwipeElement(elementScript, base:base?.subElements[id])
            }
        }
        self.subElementIds = base?.subElementIds ?? ids
        self.subElements = elements
    }
}
