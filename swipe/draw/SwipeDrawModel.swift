//
//  SwipeDrawModel.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 11/7/20.
//

import SwiftUI

class SwipeDrawModel: ObservableObject {
    @Published var currentStroke = SwipeStroke()
    @Published var isDragging = false
    @Published var location = CGPoint.zero
    @Published var strokes = [SwipeStroke]()
}

