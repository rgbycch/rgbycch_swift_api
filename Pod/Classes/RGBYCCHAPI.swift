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
import Alamofire
import SwiftyJSON

struct ServerBaseEndpoints {
    // TODO: Need to get the REST server hosted
    static let local = "http://localhost:8080/rest/v1"
    static let remote = "http://localhost:8080/rest/v1"
}

public enum RGBYCCHAPI {
    case Player(id: String)
}

protocol Path {
    var base : String { get }
    var path : String { get }
}

extension RGBYCCHAPI : Path {
    public var base: String { return RGBYCCHAPIConfiguration.sharedState.useLocalServer ? ServerBaseEndpoints.local : ServerBaseEndpoints.remote }
    var path: String {
        switch self {
        case .Player(let id):
            return "/player/\(id)"
        }
    }
}

extension RGBYCCHAPI {
    public var method: Alamofire.Method {
        switch self {
        default : return Alamofire.Method.GET
        }
    }
    public var parameters: [String: AnyObject] {
        switch self {
        default: return ["": ""]
        }
    }
    public var request: Alamofire.Request {
        return Alamofire.request(self.method, self.base + self.path, parameters: self.parameters)
    }
    public var parser: RGBYCCHAPIParser {
        switch self {
        case .Player(let id):
            return RGBYCCHAPIPlayerParser()
        }
    }
}

public class RGBYCCHAPIExecutor {
    
    public class var sharedState : RGBYCCHAPIExecutor {
        struct Static {
            static let instance = RGBYCCHAPIExecutor()
        }
        return Static.instance
    }
    
    public func executeRequest(apiContext:RGBYCCHAPI) {
        apiContext.request.responseJSON { (req, res, json, error) in
            if error != nil  {
                
            } else {
                apiContext.parser.parse(JSON(json!))
            }
        }
    }
}