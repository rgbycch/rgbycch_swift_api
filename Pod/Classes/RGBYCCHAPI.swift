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

enum RGBYCCHAPIServerBaseEndpoints : String {
    case local = "http://api.rgbycch-rest.devv"
    case remote = "http://api.rgbycch-rest.dev"
}

public enum RGBYCCHAPI {
    // sessions
    case CreateSession(email: String, password: String)
    // players
    case GetPlayerById(id: Int32)
    case GetPlayersByIds(ids: [Int32])
    case SearchPlayersByKeyword(keyword: String)
    case CreatePlayer(firstName: String, lastName: String, nickName: String?, dob: NSDate?, email: String?, phoneNumber: String?)
    case UpdatePlayer(id: Int32, firstName: String?, lastName: String?, nickName: String?, dob: NSDate?, email: String?, phoneNumber: String?)
    case DeletePlayer(id: Int32)
}

protocol Path {
    var base : String { get }
    var path : String { get }
}

extension RGBYCCHAPI : Path {
    public var base: String { return RGBYCCHAPIConfiguration.sharedState.useLocalServer ? RGBYCCHAPIServerBaseEndpoints.local.rawValue : RGBYCCHAPIServerBaseEndpoints.remote.rawValue }
    var path: String {
        switch self {
        case .CreateSession(_, _):
            return "/sessions.json"
        case .GetPlayerById(let id):
            return "/players/\(id).json"
        case .UpdatePlayer(let id, _, _, _, _, _, _):
            return "/players/\(id).json"
        case .GetPlayersByIds(_),
        .SearchPlayersByKeyword(_):
            return "/players"
        case .DeletePlayer(let id):
            return "/players/\(id).json"
        case .CreatePlayer(_, _, _, _, _, _):
            return "/players.json"
        }
    }
}

extension RGBYCCHAPI {
    public var method: Alamofire.Method {
        switch self {
        case .CreateSession(_, _),
        .CreatePlayer(_, _, _, _, _, _):
            return Alamofire.Method.POST
        case .UpdatePlayer(_, _, _, _, _, _, _):
            return Alamofire.Method.PATCH
        case .DeletePlayer(_):
            return Alamofire.Method.DELETE
        default : return Alamofire.Method.GET
        }
    }
    public var parameters: [String: AnyObject]? {
        switch self {
        case .CreateSession(let email, let password):
            return ["session": [CommonParserConstants.email.rawValue: email, "password": password]]
        case .GetPlayersByIds(let ids) :
            let stringifiedIds = ids.map({
                (number) -> String in
                return String(number)
            })
            return ["player_ids": stringifiedIds.joinWithSeparator(",")]
        case .SearchPlayersByKeyword(let keyword) :
            return ["keyword": keyword]
        case .CreatePlayer(let firstName, let lastName, let nickName, let dob, let email, let phoneNumber):
            return digestOptionalParameters(firstName, lastName:lastName, nickName:nickName, dob: dob, email: email, phoneNumber: phoneNumber)
        case .UpdatePlayer(_, let firstName, let lastName, let nickName, let dob, let email, let phoneNumber):
            return digestOptionalParameters(firstName, lastName:lastName, nickName:nickName, dob: dob, email: email, phoneNumber: phoneNumber)
        default: return nil
        }
    }
    public var encoding: ParameterEncoding {
        switch self {
        case .CreateSession(_, _),
        .CreatePlayer(_, _, _, _, _, _),
        .UpdatePlayer(_, _, _, _, _, _, _):
            return .JSON
        default: return .URL
        }
    }
    public var headers: [String: String]? {
        let apiVersionHeader = "application/vnd.rgbycch.v" + RGBYCCHAPIConfiguration.sharedState.apiVersion
        switch self {
            case .CreateSession(_, _):
            return ["Accept" : apiVersionHeader]
        default:
            if let currentUser = RGBYCCHAPICurrentUser.sharedInstance.user {
                return ["Accept" : apiVersionHeader, "Authorization" : currentUser.authToken]
            } else {
                return ["Accept" : apiVersionHeader]
            }
        }
    }
    public var request: Alamofire.Request {
        return Alamofire.request(self.method, self.base + self.path, parameters: self.parameters, encoding: self.encoding, headers:self.headers)
    }
    public var parser: RGBYCCHAPIParser {
        switch self {
        case .CreateSession(_, _):
            return RGBYCCHAPIUserParser()
        case .GetPlayerById(_),
        .CreatePlayer(_, _, _, _, _, _),
        .DeletePlayer(_):
            return RGBYCCHAPIPlayerParser()
        case .GetPlayersByIds(_),
        .SearchPlayersByKeyword(_):
            return RGBYCCHAPIPlayersParser()
        case .UpdatePlayer(_, _, _, _, _, _, _):
            return RGBYCCHAPIUpdatePlayerParser()
        }
    }
    private func digestOptionalParameters(let firstName:String?, let lastName:String?, let nickName:String?, let dob:NSDate?, let email:String?, let phoneNumber:String?) -> [String : String] {
        var params = [String : String]()
        if let unwrappedFirstName = firstName {
            params[PlayerParserConstants.firstName.rawValue] = unwrappedFirstName
        }
        if let unwrappedLastName = lastName {
            params[PlayerParserConstants.lastName.rawValue] = unwrappedLastName
        }
        if let unwrappedNickName = nickName {
            params[PlayerParserConstants.nickName.rawValue] = unwrappedNickName
        }
        if let unwrappedDateOfBirth = dob {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "YYYY-mm-dd'T'HH:mm:ss'.000Z'"
            params[PlayerParserConstants.dob.rawValue] = formatter.stringFromDate(unwrappedDateOfBirth)
        }
        if let unwrappedEmail = email {
            params[CommonParserConstants.email.rawValue] = unwrappedEmail
        }
        if let unwrappedPhoneNumber = phoneNumber {
            params[PlayerParserConstants.phone_number.rawValue] = unwrappedPhoneNumber
        }
        return params
    }
}

public class RGBYCCHAPIExecutor {
    
    public class var sharedInstance : RGBYCCHAPIExecutor {
        struct Static {
            static let instance = RGBYCCHAPIExecutor()
        }
        return Static.instance
    }
    
    public func executeRequest(apiContext:RGBYCCHAPI, completionBlock:((results:[AnyObject]?) -> Void)) throws {
        apiContext.request.responseJSON { response in
            switch response.result {
            case .Success:
                if let unwrappedData = response.data {
                    let json = JSON.init(data: unwrappedData, options: NSJSONReadingOptions.AllowFragments, error: nil)
                    let parsedResult = try! apiContext.parser.parse(json)
                    completionBlock(results:parsedResult)
                } else {
                    completionBlock(results:nil)
                }
            case .Failure(_):
                completionBlock(results:nil)
            }
        }
    }
}

public class RGBYCCHAPICurrentUser {
    var user:User?
    public class var sharedInstance : RGBYCCHAPICurrentUser {
        struct Static {
            static let instance = RGBYCCHAPICurrentUser()
        }
        return Static.instance
    }
}