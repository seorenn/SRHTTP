//
//  SRHTTP.swift
//  SRHTTP
//
//  Created by Heeseung Seo on 2015. 11. 5..
//  Copyright © 2015년 Seorenn. All rights reserved.
//

import Foundation

public typealias SRHTTPResponseBlock = (SRHTTPResponse?, NSError?) -> Void

private class SRHTTPTaskItem {
    let task: NSURLSessionTask
    let response: SRHTTPResponse
    let completionHandler: SRHTTPResponseBlock?
    
    init(task: NSURLSessionTask, response: SRHTTPResponse, completionHandler: SRHTTPResponseBlock?) {
        self.task = task
        self.response = response
        self.completionHandler = completionHandler
    }
}

public class SRHTTP: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {
    
    private lazy var session: NSURLSession = {
        return NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: self,
            delegateQueue: nil)
    }()
    private var taskItems = [SRHTTPTaskItem]()

    var headers: [String: String]? {
        set {
            self.session.configuration.HTTPAdditionalHeaders = newValue
        }
        get {
            return self.session.configuration.HTTPAdditionalHeaders as? [String: String]
        }
    }
    
    public var disableCellularAccess: Bool {
        set {
            self.session.configuration.allowsCellularAccess = !newValue
        }
        get {
            return !(self.session.configuration.allowsCellularAccess)
        }
    }
    
    public var requestTimeout: NSTimeInterval {
        set {
            self.session.configuration.timeoutIntervalForRequest = newValue
        }
        get {
            return self.session.configuration.timeoutIntervalForRequest
        }
    }
    
    public var maximumConnectionsPerHost: Int {
        set {
            self.session.configuration.HTTPMaximumConnectionsPerHost = newValue
        }
        get {
            return self.session.configuration.HTTPMaximumConnectionsPerHost
        }
    }
    
    public override init() {
        super.init()
        
        self.disableCellularAccess = false
        self.requestTimeout = 30
        self.maximumConnectionsPerHost = 1
    }
    
    public func get(URLString: String, responseHandler: SRHTTPResponseBlock) {
        guard let url = NSURL(string: URLString) else { return }
        
        let task = self.session.dataTaskWithURL(url)
        let response = SRHTTPResponse(task: task)
        let taskItem = SRHTTPTaskItem(task: task, response: response, completionHandler: responseHandler)
        self.taskItems.append(taskItem)

        task.resume()
    }
    
    public func post(URLString: String, parameters: [String: AnyObject]?, fileURLs: [NSURL]?, responseHandler: SRHTTPResponseBlock) {
        // TODO
    }
    
    // TODO: HTTP METHOD PUT
    // TODO: HTTP METHOD DELETE
    
    private func taskObject(task: NSURLSessionTask) -> SRHTTPTaskItem? {
        for item in self.taskItems {
            if item.task == task { return item }
        }
        
        return nil
    }
    
    private func removeTaskItem(taskItem: SRHTTPTaskItem) -> Bool {
        for i in 0..<self.taskItems.count {
            if self.taskItems[i].task == taskItem.task {
                self.taskItems.removeAtIndex(i)
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Delegates for NSURLSession
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        guard let taskItem = self.taskObject(dataTask) else {
            print("ERROR: Received Data of Unknown Task")
            return
        }
        
        taskItem.response.append(data)
    }
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        guard let taskItem = self.taskObject(task) else {
            print("ERROR: Received Completion of Unknown Task")
            return
        }
        
        if let handler = taskItem.completionHandler {
            handler(taskItem.response, nil)
        }
        
        if self.removeTaskItem(taskItem) == false {
            print("ERROR: Failed to remove task item")
        }
    }
}