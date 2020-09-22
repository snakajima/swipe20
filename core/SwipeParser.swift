//
//  SwipeParser.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/21/20.
//
import Foundation

struct SwipeParser {
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
    
    static let regexColor = try! NSRegularExpression(pattern: "^#[A-F0-9]*$", options: NSRegularExpression.Options.caseInsensitive)
    
    static let colorMap = [
        "clear":CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0),
        "red":CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
        "blue":CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0),
        "green":CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0),
        "black":CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
        "white":CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
        "yellow":CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0),
        "gray":CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0),
        "darkGray":CGColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0),
        "lightGray":CGColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0),
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
            return CGColor(red: red, green: green, blue: blue, alpha: alpha)
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
                    return CGColor(red: CGFloat(r)/255, green: CGFloat(g%256)/255, blue: CGFloat(b%256)/255, alpha: CGFloat(a%256)/255)
                }
                return nil
            }
        }
        return nil
    }
}
