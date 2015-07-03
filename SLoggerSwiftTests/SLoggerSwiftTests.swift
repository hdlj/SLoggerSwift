//
//  SLoggerSwiftTests.swift
//  SLoggerSwiftTests
//
//  Created by Hubert de La Jonquiere on 03/07/2015.
//  Copyright (c) 2015 Hubert de La Jonquiere. All rights reserved.
//

import UIKit
import XCTest

class SLoggerSwiftTests: XCTestCase {
    
    let log = XCGLogger.defaultInstance()
    let serverUrl = "http://sloggerswift.com/json"
    let bufferLimit=4
    
    override func setUp() {
        super.setUp()
        log.setup(logLevel: .Severe, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil)
        log.setupServeur(logLevel: XCGLogger.LogLevel.Debug,urlForServer:serverUrl , bufferLimit: bufferLimit)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAddServerToXCGLogger() {
        var logServerDestination:SLSServerLogDestination = SLSServerLogDestination(owner: XCGLogger(), identifier: "", url: "", bufferLimit: 0)
        for logdestination in log.logDestinations{
            if logdestination.identifier==XCGLogger.serverConstants.logBaseIdentifier{
                if let logdestination = logdestination as? SLSServerLogDestination {
                    logServerDestination=logdestination
                }
            }
        }
        
        XCTAssertNotNil(logServerDestination, "the logger should have at least the basic server after setupServeur")
        XCTAssertTrue(logServerDestination.owner === log," the logger is the owner of the basic serveur")
        XCTAssertEqual(logServerDestination.url, serverUrl, "the serveur use the right url")
        XCTAssertEqual(logServerDestination.bufferLimit,bufferLimit, "the serveur has the right buffer limit")
        XCTAssertTrue(logServerDestination.showFileName, "The server will received the file name for each log")
        XCTAssertTrue(logServerDestination.showLineNumber, "The srever will received the line number for each log")
        XCTAssertTrue(logServerDestination.showLogLevel, "The srever will received the log level for each log")
        XCTAssertTrue(logServerDestination.showThreadName, "The srever will received the thread name for each log")
        
        
        
        
    }
    
    func testBufferSizeForServerNotReached(){
        var logServerDestination:SLSServerLogDestination = SLSServerLogDestination(owner: XCGLogger(), identifier: "", url: "", bufferLimit: 0)
        for logdestination in log.logDestinations{
            if logdestination.identifier==XCGLogger.serverConstants.logBaseIdentifier{
                if let logdestination = logdestination as? SLSServerLogDestination {
                    logServerDestination=logdestination
                }
            }
        }
        
        log.debug("message one")
        XCTAssert(logServerDestination.bufferLog.count == 1, "message added to the buffer correctly")
    }
    
    
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
