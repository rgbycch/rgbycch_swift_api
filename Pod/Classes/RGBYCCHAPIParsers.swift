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

enum RGBYCCHAPIParserError: ErrorType {
    case RGBYCCHAPIParserEmptyResponse
    case RGBYCCHAPIParserInvalidFieldType
}

enum CommonParserConstants : String {
    case identifier = "id"
    case user = "user"
    case email = "email"
}

enum UserParserConstants : String {
    case authToken = "auth_token"
}

enum PlayerParserConstants : String {
    case firstName = "first_name"
    case lastName = "last_name"
    case nickName = "nick_name"
    case dob = "dob"
    case phone_number = "phone_number"
    case teams = "teams"
    case players = "players"
}

public protocol RGBYCCHAPIParser {
    
    func parse(json:JSON) throws -> ([AnyObject]?)
}

public class RGBYCCHAPIUserParser : RGBYCCHAPIParser {

    public func parse(json:JSON) throws -> ([AnyObject]?) {
        let user = User()
        user.identifier = json[CommonParserConstants.user.rawValue][CommonParserConstants.identifier.rawValue].int32Value
        user.email = json[CommonParserConstants.user.rawValue][CommonParserConstants.email.rawValue].stringValue
        user.authToken = json[CommonParserConstants.user.rawValue][UserParserConstants.authToken.rawValue].stringValue
        return ([user])
    }
}

public class RGBYCCHAPIPlayerParser : RGBYCCHAPIParser {
    
    public func parse(json:JSON) throws -> ([AnyObject]?) {
        return ([self.parsePlayer(json)])
    }
    
    public func parsePlayer (json:JSON) -> Player {
        let player = Player()
        player.identifier = json[CommonParserConstants.identifier.rawValue].int32Value
        player.firstName = json[PlayerParserConstants.firstName.rawValue].stringValue
        player.lastName = json[PlayerParserConstants.lastName.rawValue].stringValue
        player.nickName = json[PlayerParserConstants.nickName.rawValue].stringValue
        player.dob = json[PlayerParserConstants.dob.rawValue].stringValue
        player.email = json[CommonParserConstants.email.rawValue].stringValue
        player.phoneNumber = json[PlayerParserConstants.phone_number.rawValue].stringValue
        return player
    }
}

public class RGBYCCHAPIPlayersParser : RGBYCCHAPIParser {
    
    public func parse(json:JSON) throws -> ([AnyObject]?) {
        let playerParser = RGBYCCHAPIPlayerParser()
        let players = json[PlayerParserConstants.players.rawValue].arrayValue
        var parsedPlayers:Array<AnyObject> = []
        for entry in players {
            let player = playerParser.parsePlayer(entry)
            parsedPlayers.append(player)
        }
        return (parsedPlayers)
    }
}