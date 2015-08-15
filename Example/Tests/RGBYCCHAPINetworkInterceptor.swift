// The MIT License (MIT)

// Copyright (c) 2015 rgbycch

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

class RGBYCCHAPINetworkInterceptor: NSURLProtocol {
    
    static var responses:NSDictionary = [String: String]()
    
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        var canInitWithRequest = false
        if (RGBYCCHAPINetworkInterceptor.responses.count == 0) {
            RGBYCCHAPINetworkInterceptor.responses = ["http://localhost:8080/rest/v1/player/123" : "get_player.json"]
        }
        if let url = request.URL {
            if let absoluteURLString: AnyObject = RGBYCCHAPINetworkInterceptor.responses[url.absoluteString!] {
                canInitWithRequest = true
            }
        }
        return canInitWithRequest
    }
    
    override func startLoading() {
        if let url = self.request.URL {
            if let absoluteURLString = RGBYCCHAPINetworkInterceptor.responses[url.absoluteString!] as? NSString {
                let fileName = RGBYCCHAPINetworkInterceptor.responses[absoluteURLString] as? NSString
            }
        }
    }
    
    override func stopLoading() {
        self.client!.URLProtocolDidFinishLoading(self)
    }
    
    override var cachedResponse: NSCachedURLResponse? {
        return nil
    }
    
    override class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        return request
    }
    
    override class func requestIsCacheEquivalent(a: NSURLRequest, toRequest b: NSURLRequest) -> Bool {
        return false
    }
    
}