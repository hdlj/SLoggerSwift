//
//  SLoggerSwift.swift
//  SLoggerSwift
//
//  Created by Hubert de La Jonquiere on 03/07/2015.
//  Copyright (c) 2015 Hubert de La Jonquiere.
//  Some rights reserved: https://github.com/hdlj/SLoggerSwift/blob/master/LICENSE

import Foundation


import Foundation

public class SLSServerLogDestination : XCGLogDestinationProtocol, DebugPrintable {
    public var owner: XCGLogger
    public var identifier: String
    public var outputLogLevel: XCGLogger.LogLevel = .Debug
    public var url: String
    
    public var showThreadName: Bool = false
    public var showFileName: Bool = true
    public var showLineNumber: Bool = true
    public var showLogLevel: Bool = true
    
    public var bufferLog:[[String:String]]
    public var bufferLimit: Int = 10
    
    public init(owner: XCGLogger, identifier: String = "", url: String="", bufferLimit: Int = 10) {
        self.owner = owner
        self.identifier = identifier
        self.url=url
        self.bufferLog=[]
        self.bufferLimit=bufferLimit
    }
    
    public func processLogDetails(logDetails: XCGLogDetails) {
        #if DEBUG
            var extendedDetails: String = ""
            var threadName: String = ""
            threadName=(NSThread.isMainThread() ? "main" : (NSThread.currentThread().name != "" ? NSThread.currentThread().name : String(format:"%p", NSThread.currentThread())))
            var formattedDate: String = logDetails.date.description
            if let dateFormatter = owner.dateFormatter {
            formattedDate = dateFormatter.stringFromDate(logDetails.date)
            }
            
            var data=["date": formattedDate, "lineNumber":String(logDetails.lineNumber), "logLevel": logDetails.logLevel.description(), "fileName":logDetails.fileName, "functionName":logDetails.functionName, "message":logDetails.logMessage, "threadName":threadName]
            sendData(data)
        #endif
    }
    
    private func sendData(data:[String:String]){
        bufferLog.append(data)
        if bufferLog.count >= bufferLimit{
            let jsonDic=["data":self.bufferLog]
            self.bufferLog=[]
            dispatch_async(XCGLogger.serverQueue){ [weak self] in
                if let uSelf = self{
                    XCGLogger.printSafe("\n\nDictionnary: \(jsonDic)\n\n")
                    let json = NSJSONSerialization.dataWithJSONObject(jsonDic, options: NSJSONWritingOptions.allZeros, error: nil)
                    var request = NSMutableURLRequest(URL: NSURL(string: uSelf.url)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 5)
                    var response: NSURLResponse?
                    var error: NSError?
                    
                    
                    request.HTTPBody = json
                    request.HTTPMethod = "PUT"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    // send the request
                    NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
                    
                    // look at the response
                    if let httpResponse = response as? NSHTTPURLResponse {
                        XCGLogger.printSafe("HTTP response: \(httpResponse.statusCode)")
                    } else {
                        XCGLogger.printSafe("No HTTP response")
                    }
                    if error != nil{
                        XCGLogger.printSafe("HTTP error: \(error)")
                    } else {
                        XCGLogger.printSafe("No HTTP error")
                    }
                    
                }
                
            }
            
        }
        
    }
    
    public func processInternalLogDetails(logDetails: XCGLogDetails) {
        #if DEBUG
            var extendedDetails: String = ""
            if showLogLevel {
            extendedDetails += "[" + logDetails.logLevel.description() + "] "
            }
            
            var formattedDate: String = logDetails.date.description
            if let dateFormatter = owner.dateFormatter {
            formattedDate = dateFormatter.stringFromDate(logDetails.date)
            }
            var data=["date": formattedDate, "details": extendedDetails, "functionName": "none", "message":logDetails.logMessage]
            sendData(data)
        #endif
    }
    
    // MARK: - Misc methods
    public func isEnabledForLogLevel (logLevel: XCGLogger.LogLevel) -> Bool {
        return logLevel >= self.outputLogLevel
    }
    
    // MARK: - DebugPrintable
    public var debugDescription: String {
        get {
            return "SLSServerLogDestination: \(identifier) - LogLevel: \(outputLogLevel.description()) showThreadName: \(showThreadName) showLogLevel: \(showLogLevel) showFileName: \(showFileName) showLineNumber: \(showLineNumber)"
        }
    }
}


extension XCGLogger{
    
    
    
    public struct serverConstants {
        public static let queueIdentifier  = "sloggerswift.server.queue.identifier"
        public static let logBaseIdentifier  = "sloggerswift.server.log.base.identifier"
    }
    
    public class var serverQueue : dispatch_queue_t {
        struct ServerStatics {
            static var serverQueue = dispatch_queue_create(XCGLogger.serverConstants.queueIdentifier, nil)
        }
        return ServerStatics.serverQueue
    }
    public class func printSafe(message: String){
        dispatch_async(XCGLogger.logQueue, {
            println(message)
        })
    }
    
    public func setupServeur(logLevel: LogLevel = .Debug, showThreadName: Bool = false, showLogLevel: Bool = true, showFileNames: Bool = true, showLineNumbers: Bool = true, urlForServer:String, bufferLimit:Int ) {
        outputLogLevel = logLevel;
        let standardServerLogDestination: SLSServerLogDestination = SLSServerLogDestination(owner: self, identifier: XCGLogger.serverConstants.logBaseIdentifier, url:urlForServer, bufferLimit: bufferLimit)
        
        standardServerLogDestination.showThreadName = showThreadName
        standardServerLogDestination.showLogLevel = showLogLevel
        standardServerLogDestination.showFileName = showFileNames
        standardServerLogDestination.showLineNumber = showLineNumbers
        standardServerLogDestination.outputLogLevel = logLevel
        addLogDestination(standardServerLogDestination)
    }
    
    public class func setupServeur(logLevel: LogLevel = .Debug, showThreadName: Bool = false, showLogLevel: Bool = true, showFileNames: Bool = true, showLineNumbers: Bool = true, urlForServer:String , bufferLimit:Int ) {
        defaultInstance().setupServeur(logLevel: logLevel, showThreadName: showThreadName, showLogLevel: showLogLevel, showFileNames: showFileNames, showLineNumbers: showLineNumbers, urlForServer: urlForServer,bufferLimit: bufferLimit)
    }
    
    public class func verboseDBG(@autoclosure(escaping) closure: () -> String?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        #if DEBUG
            self.defaultInstance().logln(logLevel: .Verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
        #endif
    }
    
    public func verboseDBG(@autoclosure(escaping) closure: () -> String?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        #if DEBUG
            self.logln(logLevel: .Verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
        #endif
    }
    
    
    
    public class func debugDBG(@autoclosure(escaping) closure: () -> String?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        #if DEBUG
            self.defaultInstance().logln(logLevel: .Debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
        #endif
    }
    
    
    public func debugDBG(@autoclosure(escaping) closure: () -> String?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__){
        #if DEBUG
            self.logln(logLevel: .Debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
        #endif
    }
    
    

    public class func infoDBG(@autoclosure(escaping) closure: () -> String?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        #if DEBUG
            self.defaultInstance().logln(logLevel: .Info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
        #endif
    }
    
    
    
    public func infoDBG(@autoclosure(escaping) closure: () -> String?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        #if DEBUG
            self.logln(logLevel: .Info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
        #endif
    }
    
    
    
    public class func warningDBG(@autoclosure(escaping) closure: () -> String?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        #if DEBUG
            self.defaultInstance().logln(logLevel: .Warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
        #endif
    }
    
    
    
    public func warningDBG(@autoclosure(escaping) closure: () -> String?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        #if DEBUG
            self.logln(logLevel: .Warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
        #endif
    }
    
    
    public class func errorDBG(@autoclosure(escaping) closure: () -> String?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        #if DEBUG
            self.defaultInstance().logln(logLevel: .Error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
        #endif
    }
    
    public class func errorDBG(functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__, closure: () -> String?) {
        #if DEBUG
            self.defaultInstance().logln(logLevel: .Error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
        #endif
    }
    
    public func errorDBG(@autoclosure(escaping) closure: () -> String?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        #if DEBUG
            self.logln(logLevel: .Error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
        #endif
    }
    
    public func errorDBG(functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__, closure: () -> String?) {
        #if DEBUG
            self.logln(logLevel: .Error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
        #endif
    }
    
    public class func severeDBG(@autoclosure(escaping) closure: () -> String?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        #if DEBUG
            self.defaultInstance().logln(logLevel: .Severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
        #endif
    }
    
    public class func severeDBG(functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__, closure: () -> String?) {
        #if DEBUG
            self.defaultInstance().logln(logLevel: .Severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
        #endif
    }
    
    public func severeDBG(@autoclosure(escaping) closure: () -> String?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        #if DEBUG
            self.logln(logLevel: .Severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
        #endif
    }
    
    public func severeDBG(functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__, closure: () -> String?) {
        #if DEBUG
            self.logln(logLevel: .Severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
        #endif
    }
    
    
    
}
