//
//  SRHTTPRequest.swift
//  SRHTTP
//
//  Created by Heeseung Seo on 2015. 11. 5..
//  Copyright © 2015년 Seorenn. All rights reserved.
//

import Foundation

enum SRHTTPRequestMethod: String {
    case Get = "GET"
    case Post = "POST"
    case Put = "PUT"
    case Delete = "DELETE"
}

func generateBoundary() -> String {
    let uuid = NSUUID().UUIDString
    return "Boundary-\(uuid)"
}

class SRHTTPRequest {
    let method: SRHTTPRequestMethod
    var url: NSURL?
    var headers: [String: String]?
    var parameters: [String: AnyObject]?
    var bodyText: String?
    var data: NSData?
    var fileURL: NSURL?
    var disableCellularAccess: Bool = false
    
    private var isBuildBoundary: Bool = false
    private var boundary: String = ""
    
    init(method: SRHTTPRequestMethod, URLString: String) {
        self.method = method
        self.url = NSURL(string: URLString)
    }
    
    var URLRequest: NSURLRequest? {
        guard let url = self.url else {
            print("ERROR: There's no URL")
            return nil
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.allowsCellularAccess = !self.disableCellularAccess
        request.HTTPMethod = self.method.rawValue
        
        if let headers = self.headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        let bodyData = NSMutableData()

        if let params = self.parameters {
            for (key, value) in params {
                self.appendParameter(request, bodyData: bodyData, key: key, value: value)
            }
        }
        
        if let fileURL = self.fileURL {
            // TODO
        }
        
        if let data = self.data {
            // TODO
        }
        
        request.HTTPBody = bodyData;

        return request
    }
    
    private func checkBoudnaryBuild(request: NSMutableURLRequest) {
        if self.isBuildBoundary { return }
        
        let boundary = generateBoundary()
        self.boundary = boundary
        
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
    }
    
    private func appendBoundary(request: NSMutableURLRequest, bodyData: NSMutableData) -> Bool {
        self.checkBoudnaryBuild(request)
        
        guard let bd = "\r\n--\(self.boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding) else {
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
        
        guard let param = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding) else {
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
        
        guard let contentType = "Content-Type: application/octet-stream\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding) else {
            print("ERROR: Failed to generate content-type form-data")
            return false
        }
        
        bodyData.appendData(param)
        bodyData.appendData(contentType)
        bodyData.appendData(data)
        return true
    }
}
