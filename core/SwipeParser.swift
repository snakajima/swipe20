//
//  SwipeParser.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/21/20.
//

import Foundation

struct SwipeParser {
    static func asCGFloat(_ script:[String:Any], _ key:String, _ defaultValue:CGFloat = 0) -> CGFloat {
        if let value = script[key] as? CGFloat {
            return value
        }
        if let value = script[key] as? Int {
            return CGFloat(value)
        }
        if let value = script[key] as? Double {
            return CGFloat(value)
        }
        return defaultValue
    }
}
