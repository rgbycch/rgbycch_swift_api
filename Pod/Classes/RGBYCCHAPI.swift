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

/**
Main entry point into the `RGBYCCHAPI` API. Requests returned from this enum should be passed off to
RGBYCCHAPIExecutor to be put on the network.
*/
public enum RGBYCCHAPI {
    // sessions
    case CreateSession(email: String, password: String)
    // teams
    case GetTeamById(id: Int32)
    case GetTeamsByIds(ids: [Int32])
    case SearchTeamsByKeyword(keyword: String)
    case CreateTeam(title: String, clubId: Int32?)
    case UpdateTeam(id: Int32, title: String?, clubId:Int32?)
    case DeleteTeam(id: Int32)
    case AddPlayerToTeam(teamId: Int32, playerId: Int32)
    case RemovePlayerFromTeam(teamId: Int32, playerId: Int32)
    // players
    case GetPlayerById(id: Int32)
    case GetPlayersByIds(ids: [Int32])
    case SearchPlayersByKeyword(keyword: String)
    case CreatePlayer(firstName: String, lastName: String, nickName: String?, dob: NSDate?, email: String?, phoneNumber: String?)
    case UpdatePlayer(id: Int32, firstName: String?, lastName: String?, nickName: String?, dob: NSDate?, email: String?, phoneNumber: String?)
    case DeletePlayer(id: Int32)
    // clubs
    case GetClubById(id: Int32)
    case GetClubsByIds(ids: [Int32])
    case SearchClubsByKeyword(keyword: String)
    case CreateClub(title: String, url: String?, founded: NSDate?)
    case UpdateClub(id: Int32, title: String?, url: String?, founded: NSDate?)
    case DeleteClub(id: Int32)
    case AddTeamToClub(clubId: Int32, teamId: Int32)
    case RemoveTeamFromClub(clubId: Int32, teamId: Int32)
}

extension RGBYCCHAPI {
    public var method: Alamofire.Method {
        switch self {
        case .CreateSession(_, _),
        .CreatePlayer(_, _, _, _, _, _),
        .CreateTeam(_, _),
        .CreateClub(_, _, _):
            return Alamofire.Method.POST
        case .UpdatePlayer(_, _, _, _, _, _, _),
        .UpdateTeam(_, _, _),
        .AddPlayerToTeam(_, _),
        .RemovePlayerFromTeam(_, _),
        .UpdateClub(_, _, _, _),
        .AddTeamToClub(_, _),
        .RemoveTeamFromClub(_, _):
            return Alamofire.Method.PATCH
        case .DeletePlayer(_),
        .DeleteTeam(_),
        .DeleteClub(_):
            return Alamofire.Method.DELETE
        default : return Alamofire.Method.GET
        }
    }
    public var parameters: [String: AnyObject]? {
        switch self {
        case .CreateSession(let email, let password):
            return [ParameterConstants.session.rawValue: [CommonParserConstants.email.rawValue: email, ParameterConstants.password.rawValue: password]]
        case .GetTeamsByIds(let ids):
            return [ParameterConstants.team_ids.rawValue: ids.stringified()]
        case .SearchTeamsByKeyword(let keyword):
            return [ParameterConstants.keyword.rawValue: keyword]
        case .CreateTeam(let title, let clubId):
            var params = [String : String]()
            params[ParameterConstants.title.rawValue] = title
            if let unwrappedClubId = clubId {
                params[ParameterConstants.club_id.rawValue] = String(unwrappedClubId)
            }
            return params
        case .AddPlayerToTeam(let teamId, let playerId):
            return digestAddRemovePlayerParams(teamId, playerId: playerId)
        case .RemovePlayerFromTeam(let teamId, let playerId):
            return digestAddRemovePlayerParams(teamId, playerId: playerId)
        case .GetPlayersByIds(let ids):
            return [ParameterConstants.player_ids.rawValue: ids.stringified()]
        case .SearchPlayersByKeyword(let keyword) :
            return [ParameterConstants.keyword.rawValue: keyword]
        case .CreatePlayer(let firstName, let lastName, let nickName, let dob, let email, let phoneNumber):
            return digestOptionalTeamParameters(firstName, lastName:lastName, nickName:nickName, dob: dob, email: email, phoneNumber: phoneNumber)
        case .UpdatePlayer(_, let firstName, let lastName, let nickName, let dob, let email, let phoneNumber):
            return digestOptionalTeamParameters(firstName, lastName:lastName, nickName:nickName, dob: dob, email: email, phoneNumber: phoneNumber)
        case .GetClubsByIds(let ids):
            return [ParameterConstants.club_ids.rawValue: ids.stringified()]
        case .SearchClubsByKeyword(let keyword):
            return [ParameterConstants.keyword.rawValue: keyword]
        case .CreateClub(let title, let url, let founded):
            return digestOptionalClubParameters(title, url: url, founded: founded)
        case .UpdateClub(_, let title, let url, let founded):
            return digestOptionalClubParameters(title, url: url, founded: founded)
        case .AddTeamToClub(let clubId, let teamId):
            return digestAddRemoveTeamParams(clubId, teamId:teamId)
        case .RemoveTeamFromClub(let clubId, let teamId):
            return digestAddRemoveTeamParams(clubId, teamId:teamId)
        default: return nil
        }
    }
    public var encoding: ParameterEncoding {
        switch self {
        case .CreateSession(_, _),
        .CreateTeam(_, _),
        .UpdateTeam(_, _, _),
        .CreatePlayer(_, _, _, _, _, _),
        .UpdatePlayer(_, _, _, _, _, _, _),
        .AddPlayerToTeam(_, _),
        .RemovePlayerFromTeam(_, _),
        .CreateClub(_, _, _),
        .UpdateClub(_, _, _, _):
            return .JSON
        default: return .URL
        }
    }
    public var headers: [String: String]? {
        let apiVersionHeader = "application/vnd.rgbycch.v" + RGBYCCHAPIConfiguration.sharedState.apiVersion
        switch self {
            case .CreateSession(_, _):
            return [HeaderConstants.accept.rawValue : apiVersionHeader]
        default:
            if let currentUser = RGBYCCHAPICurrentUser.sharedInstance.user {
                return [HeaderConstants.accept.rawValue : apiVersionHeader, HeaderConstants.authorization.rawValue : currentUser.authToken]
            } else {
                return [HeaderConstants.accept.rawValue : apiVersionHeader]
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
        case .GetTeamById(_),
        .CreateTeam(_, _),
        .DeleteTeam(_):
            return RGBYCCHAPITeamParser()
        case .GetTeamsByIds(_),
        .SearchTeamsByKeyword(_):
            return RGBYCCHAPITeamsParser()
        case .UpdateTeam(_, _, _),
        .AddPlayerToTeam(_, _),
        .RemovePlayerFromTeam(_, _):
            return RGBYCCHAPIUpdateTeamParser()
        case .GetPlayerById(_),
        .CreatePlayer(_, _, _, _, _, _),
        .DeletePlayer(_):
            return RGBYCCHAPIPlayerParser()
        case .GetPlayersByIds(_),
        .SearchPlayersByKeyword(_):
            return RGBYCCHAPIPlayersParser()
        case .UpdatePlayer(_, _, _, _, _, _, _):
            return RGBYCCHAPIUpdatePlayerParser()
        case .GetClubById(_),
        .CreateClub(_, _, _),
        .DeleteClub(_):
            return RGBYCCHAPIClubParser()
        case .GetClubsByIds(_),
        .SearchClubsByKeyword(_):
            return RGBYCCHAPIClubsParser()
        case .UpdateClub(_, _, _, _),
        .AddTeamToClub(_, _),
        .RemoveTeamFromClub(_, _):
            return RGBYCCHAPIUpdateClubParser()
        }
    }
    private func digestOptionalTeamParameters(let firstName:String?, let lastName:String?, let nickName:String?, let dob:NSDate?, let email:String?, let phoneNumber:String?) -> [String : String] {
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
            formatter.dateFormat = RGBYCCHAPIDateFormat.dateFormat.rawValue
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
    private func digestOptionalClubParameters(let title:String?, let url:String?, let founded:NSDate?) -> [String : String] {
        var params = [String : String]()
        if let unwrappedTitle = title {
            params[ParameterConstants.title.rawValue] = unwrappedTitle
        }
        if let unwrappedUrl = url {
            params[ParameterConstants.url.rawValue] = unwrappedUrl
        }
        if let unwrappedFounded = founded {
            let formatter = NSDateFormatter()
            formatter.dateFormat = RGBYCCHAPIDateFormat.dateFormat.rawValue
            params[ParameterConstants.founded.rawValue] = formatter.stringFromDate(unwrappedFounded)
        }
        return params
    }
    private func digestAddRemovePlayerParams(let teamId:Int32, let playerId:Int32) -> [String: AnyObject] {
        var params = [String : NSNumber]()
        params[ParameterConstants.team_id.rawValue] = NSNumber(int: teamId)
        params[ParameterConstants.identifier.rawValue] = NSNumber(int: playerId)
        return params
    }
    private func digestAddRemoveTeamParams(let clubId:Int32, let teamId:Int32) -> [String: AnyObject] {
        var params = [String : NSNumber]()
        params[ParameterConstants.team_id.rawValue] = NSNumber(int: teamId)
        params[ParameterConstants.identifier.rawValue] = NSNumber(int: clubId)
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

public enum RGBYCCHAPIDateFormat : String {
    case dateFormat = "YYYY-mm-dd'T'HH:mm:ss'.000Z'"
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
        case .CreateTeam(_, _):
            return "/teams.json"
        case .GetTeamById(let id):
            return "/teams/\(id).json"
        case .GetTeamsByIds(_),
        .SearchTeamsByKeyword(_):
            return "/teams"
        case .UpdateTeam(let id, _, _):
            return "/teams/\(id).json"
        case .DeleteTeam(let id):
            return "/teams/\(id).json"
        case .AddPlayerToTeam(let teamId, _):
            return "/teams/\(teamId)/add_player.json"
        case .RemovePlayerFromTeam(let teamId, _):
            return "/teams/\(teamId)/remove_player.json"
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
        case .GetClubById(let id):
            return "/clubs/\(id).json"
        case .UpdateClub(let id, _, _, _):
            return "/clubs/\(id).json"
        case .GetClubsByIds(_),
        .SearchClubsByKeyword(_):
            return "/clubs"
        case .DeleteClub(let id):
            return "/clubs/\(id).json"
        case .CreateClub(_, _, _):
            return "/clubs.json"
        case .AddTeamToClub(let clubId, _):
            return "/clubs/\(clubId)/add_team.json"
        case .RemoveTeamFromClub(let clubId, _):
            return "/clubs/\(clubId)/remove_team.json"
        }
    }
}

private enum RGBYCCHAPIServerBaseEndpoints : String {
    case local = "http://api.rgbycch-rest.devv"
    case remote = "http://api.rgbycch-rest.dev"
}

private enum ParameterConstants : String {
    case session = "session"
    case keyword = "keyword"
    case team_ids = "team_ids"
    case player_ids = "player_ids"
    case password = "password"
    case title = "title"
    case club_id = "club_id"
    case team_id = "team_id"
    case identifier = "id"
    case club_ids = "club_ids"
    case url = "url"
    case founded = "founded"
}

private enum HeaderConstants : String {
    case accept = "Accept"
    case authorization = "Authorization"
}

private extension Array {
    func stringified() -> String {
        let stringifiedIds = self.map({
            (number) -> String in
            return String(number)
        })
        return stringifiedIds.joinWithSeparator(",")
    }
}