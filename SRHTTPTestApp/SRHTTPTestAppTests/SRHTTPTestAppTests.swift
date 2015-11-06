//
//  SRHTTPTestAppTests.swift
//  SRHTTPTestAppTests
//
//  Created by Heeseung Seo on 2015. 11. 5..
//  Copyright © 2015년 Seorenn. All rights reserved.
//

import XCTest
import SRHTTP
import SRJSON

class SRHTTPTestAppTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testSimpleGet() {
        let expectation = expectationWithDescription("GET /get")
        let http = SRHTTP()
        let target = "http://httpbin.org/get"
        http.get(target) {
            (response, error) in
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            XCTAssertEqual(response!.statusCode, 200)
            
            print("Reponses: \(response!.text!)")
            
            if let data = response?.data {
                if let json = SRJSON(data: data) {
                    XCTAssertEqual(json["url"]!.stringValue!, target)
                } else {
                    XCTFail()
                }
            } else {
                XCTFail()
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5) {
            error in
            if let error = error {
                print("Error: \(error)")
            }
        }
    }
}
