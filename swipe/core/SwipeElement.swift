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
    let id:String
    let image:CGImage?
    let imagePath:String?
    private let animation:[String:Any]?
    
    private(set) var pathBox = CGRect.zero
    private(set) var path:CGPath? {
        didSet {
            pathBox = path?.boundingBoxOfPath ?? .zero
        }
    }
    
    private(set) public var frame:CGRect
    private(set) public var opacity:Float
    private(set) public var anchorPoint = CGPoint(x: 0.5, y: 0.5)
    private(set) public var animationStyle:SwipeAnimation.Style
    let backgroundColor:CGColor?
    let foregroundColor:CGColor?
    private(set) public var fillColor:CGColor?
    private(set) public var strokeColor:CGColor?
    private(set) public var lineWidth:CGFloat?
    let cornerRadius:CGFloat?
    let text:String?
    let filter:[String:Any]?
    let src:[String:Any]?
    public var isHidden:Bool
    public var rotX, rotY, rotZ:CGFloat

    let subElementIds:[String]
    let subElements:[String:SwipeElement]

    /// Initializes an element with specified description. base is an element on the previous frame with the same id
    init(_ script:[String:Any], id:String, base:SwipeElement?) {
        self.id = id
        self.filter = script["filter"] as? [String:Any]
        self.src = script["src"] as? [String:Any]
        
        let origin = base?.frame.origin ?? CGPoint.zero
        let size = base?.frame.size ?? CGSize(width: 100, height: 100)
        self.frame = CGRect(x: SwipeParser.asCGFloat(script["x"]) ?? origin.x,
                       y: SwipeParser.asCGFloat(script["y"]) ?? origin.y,
                       width: SwipeParser.asCGFloat(script["w"]) ?? size.width,
                       height: SwipeParser.asCGFloat(script["h"]) ?? size.height)

        self.isHidden = script["hidden"] as? Bool ?? false
        self.backgroundColor = SwipeParser.parseColor(script["backgroundColor"]) ?? base?.backgroundColor
        self.foregroundColor = SwipeParser.parseColor(script["foregroundColor"]) ?? base?.foregroundColor
        self.fillColor = SwipeParser.parseColor(script["fillColor"]) ?? base?.fillColor
        self.strokeColor = SwipeParser.parseColor(script["strokeColor"]) ?? base?.strokeColor
        self.lineWidth = SwipeParser.asCGFloat(script["lineWidth"]) ?? base?.lineWidth
        self.cornerRadius = SwipeParser.asCGFloat(script["cornerRadius"]) ?? base?.cornerRadius
        self.opacity = SwipeParser.asFloat(script["opacity"]) ?? base?.opacity ?? 1.0
 
        var style = SwipeAnimation.Style.normal
        if let animation = script["animation"] as? [String:Any] ?? base?.animation {
            self.animation = animation
           if let rawValue = animation["style"] as? String {
            style = SwipeAnimation.Style(rawValue: rawValue) ?? .normal
           }
        } else {
            self.animation = nil
        }
        self.animationStyle = style

        // NOTE: To be filled about the inheritance
        if let rot = SwipeParser.asCGFloat(script["rotate"]) {
            self.rotX = 0
            self.rotY = 0
            self.rotZ = rot / 180 * .pi
        } else if let rots = SwipeParser.asCGFloats(script["rotate"]), rots.count == 3 {
            self.rotX = rots[0] / 180 * .pi
            self.rotY = rots[1] / 180 * .pi
            self.rotZ = rots[2] / 180 * .pi
        } else {
            self.rotX = 0
            self.rotY = 0
            self.rotZ = 0
        }

        // NOTE: "text" and "img" are not animatable. Therefore, we don't need to handle inhericance
        self.text = script["text"] as? String
        var imagePath:String? = nil
        if let imageName = script["img"] as? String {
            #if os(iOS) || os(watchOS) || os(tvOS)
            self.image = UIImage(named: imageName)?.cgImage
            #elseif os(macOS)
            self.image = NSImage(named: imageName)?.cgImage(forProposedRect: nil, context: nil, hints: nil)
            #endif
            imagePath = Bundle.main.path(forResource: imageName, ofType: nil)
        } else {
            self.image = nil
        }
        self.imagePath = imagePath
        
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
                elements[id] = SwipeElement(elementScript, id:id, base:base?.subElements[id])
            }
        }
        self.subElementIds = base?.subElementIds ?? ids
        self.subElements = elements
    }
    
    func hitTest(point:CGPoint) -> Bool {
        return frame.contains(point)
    }

    func updated(animationStyle:SwipeAnimation.Style) -> SwipeElement {
        var element = self
        element.animationStyle = animationStyle
        return element
    }
    
    func updated(frame:CGRect) -> SwipeElement {
        var element = self
        element.frame = frame
        return element
    }

    func updated(strokeColor:CGColor, lineWidth:CGFloat, fillColor:CGColor = OSColor.clear.cgColor) -> SwipeElement {
        var element = self
        element.strokeColor = strokeColor
        element.lineWidth = lineWidth
        element.fillColor = fillColor
        return element
    }

    func updated(deltaRotZ rotZinput:CGFloat) -> SwipeElement {
        var rotZ = rotZinput
        while (rotZ < 0) {
            rotZ += 2 * .pi
        }
        var element = self
        print("rotX", rotZ)
        element.rotZ += rotZ > .pi ? rotZ - 2 * .pi : rotZ
        return element
    }
    
    func updated(path:CGPath) -> SwipeElement {
        var element = self
        element.path = path
        return element
    }
    
    func updated(isHidden:Bool) -> SwipeElement {
        var element = self
        element.isHidden = isHidden
        return element
    }
    
    var script:[String:Any] {
        var script:[String:Any] = [
            "id":id,
            "x":frame.minX,
            "y":frame.minY,
            "w":frame.width,
            "h":frame.height
        ]
        if let text = self.text {
            script["text"] = text
        }
        if let imagePath = self.imagePath {
            script["img"] = imagePath
        }
        if isHidden {
            script["hidden"] = true
        }
        if let animation = self.animation {
            script["animation"] = animation
        }
        if let filter = self.filter {
            script["filter"] = filter
        }
        if let lineWidth = self.lineWidth {
            script["lineWidth"] = lineWidth
        }
        if let cornerRadius = self.cornerRadius {
            script["cornerRadius"] = cornerRadius
        }
        if let backgroundColor = self.backgroundColor,
           let components = backgroundColor.components, components.count == 4 {
            script["backgroundColor"] = components
        }
        if let foregroundColor = self.foregroundColor,
           let components = foregroundColor.components, components.count == 4 {
            script["foregroundColor"] = components
        }
        if let fillColor = self.fillColor,
           let components = fillColor.components, components.count == 4 {
            script["fillColor"] = components
        }
        return script
    }
}

extension SwipeElement : SwipeRenderProperties {
}
