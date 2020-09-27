//
//  swipeTests.swift
//  swipeTests
//
//  Created by SATOSHI NAKAJIMA on 9/26/20.
//

import XCTest
@testable import swipe

class swipeTests: XCTestCase {
    var swipe:Swipe!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        swipe = Swipe()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAdd() {
        XCTAssertEqual(swipe.add(a: 1, b: 1), 2)
    }
    
    func testSub() {
            XCTAssertEqual(swipe.sub(a: 2, b: 1), 1)
    }
}
