//
//  SRHTTPRequest.swift
//  SRHTTP
//
//  Created by Heeseung Seo on 2015. 11. 5..
//  Copyright © 2015년 Seorenn. All rights reserved.
//

import Foundation

func generateBoundary() -> String {
    return NSUUID().UUIDString
}

class SRHTTPRequest {
    let method: SRHTTPMethod
    var URL: NSURL?
    var headers: [String: String]?
    var parameters: [String: AnyObject]?
    var bodyText: String?
    var data: NSData?
    var fileURL: NSURL?
    
    private var boundary: String?
    
    init(method: SRHTTPMethod, URL: NSURL) {
        self.method = method
        self.URL = URL
    }
    
    var URLRequest: NSURLRequest? {
        guard let url = self.URL else {
            print("ERROR: There's no URL")
            return nil
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = self.method.rawValue
        
        if let headers = self.headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        let bodyData = NSMutableData()

        if let params = self.parameters {
            for (key, value) in params {
                if self.appendParameter(request, bodyData: bodyData, key: key, value: value) == false {
                    print("Failed to append parameter \(key) = \(value)")
                }
            }
        }
        
        if let fileURL = self.fileURL {
            if let fileData = NSData(contentsOfURL: fileURL) {
                self.appendFile(request, bodyData: bodyData, key: "file", filename: fileURL.lastPathComponent!, data: fileData)
            }
            else {
                print("ERROR: Failed to load file \(fileURL)")
            }
            // TODO
        }
        
        if let data = self.data {
            self.appendFile(request, bodyData: bodyData, key: "file", filename: "untitled", data: data)
            // TODO
        }
        
        if let boundary = self.boundary {
            let eof = "--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!
            bodyData.appendData(eof)
        }
        
        request.HTTPBody = bodyData;

        return request
    }
    
    private func checkBoudnaryBuild(request: NSMutableURLRequest) {
        if let _ = self.boundary {
            return
        }
        
        self.boundary = generateBoundary()
        
        let contentType = "multipart/form-data; boundary=\(self.boundary!)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
    }
    
    private func appendBoundary(request: NSMutableURLRequest, bodyData: NSMutableData) -> Bool {
        self.checkBoudnaryBuild(request)
        
        guard let bd = "--\(self.boundary!)\r\n".dataUsingEncoding(NSUTF8StringEncoding) else {
            print("ERROR: Failed to generate boundary data")
            return false
        }
        
        bodyData.appendData(bd)
        return true
    }
    
    func appendParameter(request: NSMutableURLRequest, bodyData: NSMutableData, key: String, value: AnyObject) -> Bool {
        if self.appendBoundary(request, bodyData: bodyData) == false {
            print("Error: Failed to append boundary")
            return false
        }
        
        guard let param = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)\r\n".dataUsingEncoding(NSUTF8StringEncoding) else {
            print("ERROR: Failed to generate form-data")
            return false
        }
        
        bodyData.appendData(param)
        return true
    }
    
    func appendFile(request: NSMutableURLRequest, bodyData: NSMutableData, key: String, filename: String, data: NSData) -> Bool {
        if self.appendBoundary(request, bodyData: bodyData) == false {
            print("Error: Failed to append boundary")
            return false
        }
        
        guard let param = "Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding) else {
            print("ERROR: Failed to generate form-data")
            return false
        }
        
        // TODO: Content-Type Generation for Real Content Type :-(
        guard let contentType = "Content-Type: application/octet-stream\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding) else {
            print("ERROR: Failed to generate content-type form-data")
            return false
        }
        
        guard let eof = "\r\n".dataUsingEncoding(NSUTF8StringEncoding) else {
            print("ERROR: Failed to generate EOF data")
            return false
        }
        
        bodyData.appendData(param)
        bodyData.appendData(contentType)
        bodyData.appendData(data)
        bodyData.appendData(eof)
        return true
    }
}
