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
import SwiftyJSON

struct PlayerParserConstants {
    static let identifier = "id"
    static let firstName = "firstName"
    static let lastName = "lastName"
    static let nickName = "nickName"
    static let primaryPosition = "primaryPosition"
    static let secondaryPosition = "secondaryPosition"
    static let tertiaryPosition = "tertiaryPosition"
    static let teamList = "teamList"
}

public protocol RGBYCCHAPIParser {
    
    func parse (json:JSON) -> (results:Array<AnyObject>?, error:NSError?)
}

public class RGBYCCHAPIPlayerParser : RGBYCCHAPIParser {
    
    public func parse (json:JSON) -> (results:Array<AnyObject>?, error:NSError?) {
        var player = Player()
        player.identifier = json[PlayerParserConstants.identifier].stringValue
        player.firstName = json[PlayerParserConstants.firstName].stringValue
        player.lastName = json[PlayerParserConstants.lastName].stringValue
        player.nickName = json[PlayerParserConstants.nickName].stringValue
        return ([player], nil)
    }
}