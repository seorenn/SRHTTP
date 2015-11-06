//
//  SRHTTPResponse.swift
//  SRHTTP
//
//  Created by Heeseung Seo on 2015. 11. 5..
//  Copyright © 2015년 Seorenn. All rights reserved.
//

import Foundation

public class SRHTTPResponse {
    internal let task: NSURLSessionTask
    private let receivedData: NSMutableData
    
    internal var response: NSURLResponse? {
        return self.task.response
    }
    
    internal var HTTPResponse: NSHTTPURLResponse? {
        return self.task.response as? NSHTTPURLResponse
    }
    
    public var data: NSData? {
        if self.receivedData.length <= 0 { return nil }
        return self.receivedData
    }
    
    public var text: String? {
        guard let data = self.data else { return nil }
        return String(data: data, encoding: NSUTF8StringEncoding)
    }
    
    public var statusCode: Int {
        guard let res = self.HTTPResponse else { return 0 }
        return res.statusCode
    }
    
    public init(task: NSURLSessionTask) {
        self.task = task
        self.receivedData = NSMutableData()
    }
    
//    public init(data: NSData?, response: NSURLResponse) {
//        self.data = data
//        self.response = response
//        self.HTTPResponse = response as! NSHTTPURLResponse
//    }
    
    internal func append(data: NSData) {
        self.receivedData.appendData(data)
    }
    
//    func appendData(data: NSData) {
//        if self.receivedData == nil {
//            self.receivedData = NSMutableData()
//        }
//        
//        self.receivedData?.appendData(data)
//    }
}
