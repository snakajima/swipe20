//
//  SwipeElement.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//
import Foundation
import CoreImage
#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

/// A structure that describes an element to be displayed on a scene
public struct SwipeElement {
    let script:[String:Any]
    let name:String?
    let image:CGImage?
    let path:CGPath?
    
    private(set) public var frame:CGRect
    private(set) public var opacity:Float
    private(set) public var anchorPoint:CGPoint
    private(set) public var animationStyle:SwipeAnimation.Style
    let backgroundColor:CGColor?
    let foregroundColor:CGColor?
    let fillColor:CGColor?
    let strokeColor:CGColor?
    let lineWidth:CGFloat?
    let cornerRadius:CGFloat?
    public let rotX, rotY, rotZ:CGFloat

    let subElementIds:[String]
    let subElements:[String:SwipeElement]

    /// Initializes an element with specified description. base is an element on the previous frame with the same id
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
        self.opacity = SwipeParser.asFloat(script["opacity"]) ?? base?.opacity ?? 1.0
        if let points = SwipeParser.asCGFloats(script["anchorPoint"]), points.count == 2 {
            self.anchorPoint = CGPoint(x: points[0], y: points[1])
        } else {
            self.anchorPoint = base?.anchorPoint ?? CGPoint(x: 0.5, y: 0.5)
        }

        if let rot = SwipeParser.asCGFloat(script["rotate"]) {
            self.rotX = 0
            self.rotY = 0
            self.rotZ = rot
        } else if let rots = SwipeParser.asCGFloats(script["rotate"]), rots.count == 3 {
            self.rotX = rots[0]
            self.rotY = rots[1]
            self.rotZ = rots[2]
        } else {
            self.rotX = 0
            self.rotY = 0
            self.rotZ = 0
        }
        
        if let imageName = script["img"] as? String {
            #if os(iOS) || os(watchOS) || os(tvOS)
            self.image = UIImage(named: imageName)?.cgImage
            #elseif os(macOS)
            self.image = NSImage(named: imageName)?.cgImage(forProposedRect: nil, context: nil, hints: nil)
            #endif
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

        var style = SwipeAnimation.Style.normal
        if let animation = script["animation"] as? [String:Any],
           let rawValue = animation["style"] as? String {
            style = SwipeAnimation.Style(rawValue: rawValue) ?? .normal
        }
        self.animationStyle = style
    }
    
    func hitTest(point:CGPoint) -> Bool {
        return frame.contains(point)
    }
}

extension SwipeElement : SwipeRenderProperties {
}
