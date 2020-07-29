//
//  NeedToMeasureDrinkTests.swift
//  NeedToMeasureDrinkTests
//
//  Created by 백상휘 on 2020/06/18.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import XCTest

@testable import NeedToMeasureDrink

class NeedToMeasureDrinkTests: XCTestCase {
    var applicationTest: MainViewController!
    
    override func setUp() {
        super.setUp()
        applicationTest = MainViewController()
    }
    
    override func tearDown() { // 분해 하다
        super.tearDown()
        applicationTest = nil
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
