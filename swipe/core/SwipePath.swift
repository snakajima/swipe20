//
//  SwipePath.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/23/20.
//

import Cocoa
import SwiftUI

/// A structure that defines a static parse functions
struct SwipePath {

    private static let regexSVG = try! NSRegularExpression(pattern: "[a-z][0-9\\-\\.,\\s]*", options: NSRegularExpression.Options.caseInsensitive)
    private static let regexNUM = try! NSRegularExpression(pattern: "[\\-]*[0-9\\.]+", options: NSRegularExpression.Options())

    /// Parses a SVG style path and reurns a CGPath
    static func parse(_ shape:Any?) -> CGPath? {
        guard let string = shape as? String else {
            return nil
        }
        
        //NSLog("SwipePath \(string)")
        let matches = SwipePath.regexSVG.matches(in: string, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, string.count))
        //NSLog("SwipePath \(matches)")
        let path = CGMutablePath()
        var pt = CGPoint.zero
        var cp = CGPoint.zero // last control point for S command
        var prevIndex = string.startIndex // for performance
        var prevOffset = 0
        for match in matches {
            var start = string.index(prevIndex, offsetBy: match.range.location - prevOffset)
            let cmd = string[start..<string.index(start, offsetBy: 1)]
            start = string.index(start, offsetBy: 1)
            let end = string.index(start, offsetBy: match.range.length-1)
            prevIndex = end
            prevOffset = match.range.location + match.range.length
            
            let params = string[start..<end]
            let nums = SwipePath.regexNUM.matches(in: String(params), options: [], range: NSMakeRange(0, params.count))
            let p = nums.map({ (num) -> CGFloat in
                let start = params.index(params.startIndex, offsetBy: num.range.location)
                let end = params.index(start, offsetBy: num.range.length)
                return CGFloat((params[start..<end] as NSString).floatValue)
            })
            //NSLog("SwipeElement \(cmd) \(p) #\(p.count)")
            switch(cmd) {
            case "m":
                if p.count == 2 {
                    path.move(to: CGPoint(x: pt.x+p[0], y: pt.y+p[1]))
                    pt.x += p[0]
                    pt.y += p[1]
                }
            case "M":
                if p.count == 2 {
                    path.move(to: CGPoint(x: p[0], y: p[1]))
                    pt.x = p[0]
                    pt.y = p[1]
                }
            case "z":
                path.closeSubpath()
                break
            case "Z":
                path.closeSubpath()
                break
            case "c":
                var i = 0
                while(p.count >= i+6) {
                    path.addCurve(to: CGPoint(x: pt.x+p[i+4], y: pt.y+p[i+5]), control1: CGPoint(x: pt.x+p[i], y: pt.y+p[i+1]), control2: CGPoint(x: pt.x+p[i+2], y: pt.y+p[i+3]))
                    cp.x = pt.x+p[i+2]
                    cp.y = pt.y+p[i+3]
                    pt.x += p[i+4]
                    pt.y += p[i+5]
                    i += 6
                }
            case "C":
                var i = 0
                while(p.count >= i+6) {
                    path.addCurve(to: CGPoint(x: p[i+4], y: p[i+5]), control1: CGPoint(x: p[i], y: p[i+1]), control2: CGPoint(x: p[i+2], y: p[i+3]))
                    cp.x = p[i+2]
                    cp.y = p[i+3]
                    pt.x = p[i+4]
                    pt.y = p[i+5]
                    i += 6
                }
            case "q":
                var i = 0
                while(p.count >= i+4) {
                    path.addQuadCurve(to: CGPoint(x: pt.x+p[i+2], y: pt.y+p[i+3]), control: CGPoint(x: pt.x+p[i], y: pt.y+p[i+1]))
                    cp.x = pt.x+p[i]
                    cp.y = pt.y+p[i+1]
                    pt.x += p[i+2]
                    pt.y += p[i+3]
                    i += 4
                }
            case "Q":
                var i = 0
                while(p.count >= i+4) {
                    path.addQuadCurve(to: CGPoint(x: p[i+2], y: p[i+3]), control: CGPoint(x: p[i], y: p[i+1]))
                    cp.x = p[i]
                    cp.y = p[i+1]
                    pt.x = p[i+2]
                    pt.y = p[i+3]
                    i += 4
                }
            case "s":
                var i = 0
                while(p.count >= i+4) {
                    path.addCurve(to: CGPoint(x: pt.x+p[i+2], y: pt.y+p[i+3]), control1: CGPoint(x: pt.x * 2 - cp.x, y: pt.y * 2 - cp.y), control2: CGPoint(x: pt.x+p[i], y: pt.y+p[i+1]))
                    cp.x = pt.x + p[i]
                    cp.y = pt.y + p[i+1]
                    pt.x += p[i+2]
                    pt.y += p[i+3]
                    i += 4
                }
            case "S":
                var i = 0
                while(p.count >= i+4) {
                    path.addCurve(to: CGPoint(x: p[i+2], y: p[i+3]), control1: CGPoint(x: pt.x * 2 - cp.x, y: pt.y * 2 - cp.y), control2: CGPoint(x: p[i], y: p[i+1]))
                    cp.x = p[i]
                    cp.y = p[i+1]
                    pt.x = p[i+2]
                    pt.y = p[i+3]
                    i += 4
                }
            case "l":
                var i = 0
                while(p.count >= i+2) {
                    path.addLine(to: CGPoint(x: pt.x+p[i], y: pt.y+p[i+1]))
                    pt.x += p[i]
                    pt.y += p[i+1]
                    i += 2
                }
            case "L":
                var i = 0
                while(p.count >= i+2) {
                    path.addLine(to: CGPoint(x: p[i], y: p[i+1]))
                    pt.x = p[i]
                    pt.y = p[i+1]
                    i += 2
                }
            case "v":
                var i = 0
                while(p.count >= i+1) {
                    path.addLine(to: CGPoint(x: pt.x, y: pt.y+p[i]))
                    pt.y += p[i]
                    i += 1
                }
            case "V":
                var i = 0
                while(p.count >= i+1) {
                    path.addLine(to: CGPoint(x: pt.x, y: p[i]))
                    pt.y = p[i]
                    i += 1
                }
            case "h":
                var i = 0
                while(p.count >= i+1) {
                    path.addLine(to: CGPoint(x: pt.x+p[i], y: pt.y))
                    pt.x += p[i]
                    i += 1
                }
            case "H":
                var i = 0
                while(p.count >= i+1) {
                    path.addLine(to: CGPoint(x: p[i], y: pt.y))
                    pt.x = p[i]
                    i += 1
                }
            default:
                NSLog("SwipeElement ### unknown \(cmd)")
                break;
            }
        }
        return path
    }
}

struct SwipePath_Previews: PreviewProvider {
    static var previews: some View {
        SwipeFileView("Shapes")
    }
}

