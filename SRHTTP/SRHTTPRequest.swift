//
//  SRHTTPRequest.swift
//  SRHTTP
//
//  Created by Heeseung Seo on 2015. 11. 5..
//  Copyright © 2015년 Seorenn. All rights reserved.
//

import Foundation

public enum SRHTTPRequestMethod: String {
    case Get = "GET"
    case Post = "POST"
    case Put = "PUT"
    case Delete = "DELETE"
}

public class SRHTTPRequest: NSObject {
    var method: SRHTTPRequestMethod
    var url: NSURL?
    var urlString: String {
        didSet {
            self.url = NSURL(string: self.urlString)
        }
    }
    var headers: [String: String] = [:]
    var formValues: [String: AnyObject] = [:]
    var bodyText: String?
    var uploadFileData: NSData?
    
    init(method: SRHTTPRequestMethod, urlString: String) {
        self.method = method
        self.urlString = urlString
        
        super.init()
    }
    
    var urlRequest: NSURLRequest? {
        let url = self.url
        if url == nil { return nil }
        let request = NSMutableURLRequest(URL: url!)
        
        if self.headers.count > 0 {
            for (key, value) in self.headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        if self.formValues.count > 0 {
            // TODO
        }
        
        // TODO
        return nil
    }
}
