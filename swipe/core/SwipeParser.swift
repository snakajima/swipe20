//
//  SwipeParser.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/21/20.
//
import Foundation
import Cocoa
#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
typealias OSColor = UIColor
#elseif os(macOS)
typealias OSColor = NSColor
#endif


// A sollection of helper functions for parsing Swipe script
struct SwipeParser {
    static func asFloat(_ inputValue:Any?) -> Float? {
        if let value = inputValue as? Float {
            return value
        }
        if let value = inputValue as? Int {
            return Float(value)
        }
        if let value = inputValue as? CGFloat {
            return Float(value)
        }
        return nil
    }

    static func asCGFloat(_ inputValue:Any?) -> CGFloat? {
        if let value = inputValue as? CGFloat {
            return value
        }
        if let value = inputValue as? Int {
            return CGFloat(value)
        }
        if let value = inputValue as? Double {
            return CGFloat(value)
        }
        return nil
    }

    static func asCGFloats(_ inputValue:Any?) -> [CGFloat]? {
        if let array = inputValue as? [CGFloat] {
            return array
        }
        if let array = inputValue as? [Int] {
            return array.map { CGFloat($0) }
        }
        if let array = inputValue as? [Double] {
            return array.map { CGFloat($0) }
        }
        return []
    }
    
    static let regexColor = try! NSRegularExpression(pattern: "^#[A-F0-9]*$", options: NSRegularExpression.Options.caseInsensitive)
    
    static let colorMap = [
        "clear":OSColor.clear.cgColor,
        "red":OSColor.red.cgColor,
        "blue":OSColor.blue.cgColor,
        "green":OSColor.green.cgColor,
        "black":OSColor.black.cgColor,
        "white":OSColor.white.cgColor,
        "yellow":OSColor.yellow.cgColor,
        "gray":OSColor.gray.cgColor,
        "darkGray":OSColor.darkGray.cgColor,
        "lightGray":OSColor.lightGray.cgColor,
    ]
    
    static func parseColor(_ value:Any?) -> CGColor? {
        if let rgba = value as? [String: Any] {
            var red:CGFloat = 0.0, blue:CGFloat = 0.0, green:CGFloat = 0.0
            var alpha:CGFloat = 1.0
            if let v = rgba["r"] as? CGFloat {
                red = v
            }
            if let v = rgba["g"] as? CGFloat {
                green = v
            }
            if let v = rgba["b"] as? CGFloat {
                blue = v
            }
            if let v = rgba["a"] as? CGFloat {
                alpha = v
            }
            return OSColor(red: red, green: green, blue: blue, alpha: alpha).cgColor
        } else if let key = value as? String {
            if let color = colorMap[key] {
                return color
            } else {
                let results = regexColor.matches(in: key, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, key.count))
                if results.count > 0 {
                    let hex = String(key.dropFirst())
                    let cstr = hex.cString(using: String.Encoding.ascii)
                    let v = strtoll(cstr!, nil, 16)
                    //NSLog("SwipeParser hex=\(hex), \(value)")
                    var r = Int64(0), g = Int64(0), b = Int64(0), a = Int64(255)
                    switch(hex.count) {
                    case 3:
                        r = v / 0x100 * 0x11
                        g = v / 0x10 % 0x10 * 0x11
                        b = v % 0x10 * 0x11
                    case 4:
                        r = v / 0x1000 * 0x11
                        g = v / 0x100 % 0x10 * 0x11
                        b = v / 0x10 % 0x10 * 0x11
                        a = v % 0x10 * 0x11
                    case 6:
                        r = v / 0x10000
                        g = v / 0x100
                        b = v
                    case 8:
                        r = v / 0x1000000
                        g = v / 0x10000
                        b = v / 0x100
                        a = v
                    default:
                        break;
                    }
                    return OSColor(red: CGFloat(r)/255, green: CGFloat(g%256)/255, blue: CGFloat(b%256)/255, alpha: CGFloat(a%256)/255).cgColor
                }
                return nil
            }
        }
        return nil
    }
}
