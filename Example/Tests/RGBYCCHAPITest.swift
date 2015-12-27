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

import Quick
import Nimble
import OHHTTPStubs

import rgbycch_swift_api

class RGBYCCHAPITest: QuickSpec {
    
    override func spec() {
        
        describe("RGBYCCHAPI") {
            
            beforeEach({ () -> () in
                let map = [
                    "http://api.rgbycch-rest.dev/sessions.json" : "create_session.json",
                    "http://api.rgbycch-rest.dev/teams/123.json" : "get_team_by_id.json",
                    "http://api.rgbycch-rest.dev/teams?team_ids=123%2C456" : "get_teams_by_ids.json",
                    "http://api.rgbycch-rest.dev/teams?keyword=und" : "search_teams.json",
                    "http://api.rgbycch-rest.dev/teams.json" : "create_team.json",
                    "http://api.rgbycch-rest.dev/teams/456.json" : "update_team.json",
                    "http://api.rgbycch-rest.dev/teams/789.json" : "delete_team.json",
                    "http://api.rgbycch-rest.dev/teams/777/add_player.json" : "add_player.json",
                    "http://api.rgbycch-rest.dev/teams/777/remove_player.json" : "remove_player.json",
                    "http://api.rgbycch-rest.dev/event_types/123.json" : "get_event_type_by_id.json",
                    "http://api.rgbycch-rest.dev/event_types?event_type_ids=123%2C456" : "get_event_types_by_ids.json",
                    "http://api.rgbycch-rest.dev/event_types?keyword=und" : "search_event_types.json",
                    "http://api.rgbycch-rest.dev/event_types.json" : "create_event_type.json",
                    "http://api.rgbycch-rest.dev/event_types/456.json" : "update_event_type.json",
                    "http://api.rgbycch-rest.dev/event_types/789.json" : "delete_event_type.json",
                    "http://api.rgbycch-rest.dev/players/123.json" : "get_player_by_id.json",
                    "http://api.rgbycch-rest.dev/players?player_ids=123%2C456" : "get_players_by_ids.json",
                    "http://api.rgbycch-rest.dev/players?keyword=rugg" : "search_players.json",
                    "http://api.rgbycch-rest.dev/players.json" : "create_player.json",
                    "http://api.rgbycch-rest.dev/players/789.json" : "delete_player.json",
                    "http://api.rgbycch-rest.dev/players/456.json" : "update_player.json",
                    "http://api.rgbycch-rest.dev/clubs/123.json" : "get_club_by_id.json",
                    "http://api.rgbycch-rest.dev/clubs?club_ids=123%2C456" : "get_clubs_by_ids.json",
                    "http://api.rgbycch-rest.dev/clubs?keyword=clon" : "search_clubs.json",
                    "http://api.rgbycch-rest.dev/clubs.json" : "create_club.json",
                    "http://api.rgbycch-rest.dev/clubs/789.json" : "delete_club.json",
                    "http://api.rgbycch-rest.dev/clubs/456.json" : "update_club.json",
                    "http://api.rgbycch-rest.dev/clubs/777/add_team.json" : "add_team.json",
                    "http://api.rgbycch-rest.dev/clubs/777/remove_team.json" : "remove_team.json"]
                for (absoluteString, fileName) in map {
                    OHHTTPStubs.stubRequestsPassingTest({$0.URL!.absoluteString == absoluteString}) { _ in
                        let fixture = OHPathForFile(fileName, self.dynamicType)
                        return OHHTTPStubsResponse(fileAtPath: fixture!,
                            statusCode: 200, headers: ["Content-Type" : "application/json"])
                    }
                }
            })
            
            afterEach({ () -> () in
                OHHTTPStubs.removeAllStubs()
            })
            
            context("Testing Session API calls") {
                
                it("should be able to construct the url correctly for a create session call") {

                    let sessionRequest = RGBYCCHAPI.CreateSession(email: "email", password: "password").request
                    let sessionRequestURLString = sessionRequest.request?.URL?.absoluteString
                    
                    expect(sessionRequestURLString).to(equal("http://api.rgbycch-rest.dev/sessions.json"))
                }
                
                it("should be able to execute a request to create a session") {
                    
                    let expectation = self.expectationWithDescription("CreateSessionCompletion")
                    
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.CreateSession(email: "email", password: "password"), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should return one user for a create session call after parsing") {
                    
                    let expectation = self.expectationWithDescription("CreateSessionCompletion")
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.CreateSession(email: "email", password: "password"), completionBlock: { (results) -> Void in
                            if let users = results as? [User] {
                                let user:User = users[0]
                                expect(user.identifier).to(equal(1))
                                expect(user.email).to(equal("tom@rgbycch.com"))
                                expect(user.authToken).to(equal("JV6hahPkdAT7fiaJjnsH"))
                                expectation.fulfill()
                            } else {
                                XCTFail("api call failed")
                            }
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }

            }
            
            context("Testing Teams API calls") {
                
                it("should be able to construct the url correctly for a GetTeamById call") {
                    
                    let teamRequest = RGBYCCHAPI.GetTeamById(id: 123).request
                    let teamRequestURLString = teamRequest.request?.URL?.absoluteString
                    
                    expect(teamRequestURLString).to(equal("http://api.rgbycch-rest.dev/teams/123.json"))
                }
                
                it("should be able to construct the url correctly for a GetTeamsByIds call") {
                    
                    let teamRequest = RGBYCCHAPI.GetTeamsByIds(ids: [123, 456]).request
                    let teamRequestURLString = teamRequest.request?.URL?.absoluteString
                    
                    expect(teamRequestURLString).to(equal("http://api.rgbycch-rest.dev/teams?team_ids=123%2C456"))
                }
                
                it("should be able to construct the url correctly for a SearchTeamsByKeyword call") {
                    
                    let teamRequest = RGBYCCHAPI.SearchTeamsByKeyword(keyword: "und").request
                    let teamRequestURLString = teamRequest.request?.URL?.absoluteString
                    
                    expect(teamRequestURLString).to(equal("http://api.rgbycch-rest.dev/teams?keyword=und"))
                }
                
                it("should be able to construct the url correctly for creating a team call") {
                    
                    let teamRequest = RGBYCCHAPI.CreateTeam(title: "Team Title", clubId: 123).request
                    let teamRequestURLString = teamRequest.request?.URL?.absoluteString
                    
                    expect(teamRequestURLString).to(equal("http://api.rgbycch-rest.dev/teams.json"))
                }
                
                it("should be able to construct the url correctly for a UpdateTeam call") {
                    
                    let teamRequest = RGBYCCHAPI.UpdateTeam(id: 456, title: "Updated Team Title", clubId: 123).request
                    let teamRequestURLString = teamRequest.request?.URL?.absoluteString
                    
                    expect(teamRequestURLString).to(equal("http://api.rgbycch-rest.dev/teams/456.json"))
                }
                
                it("should be able to construct the url correctly for a DeleteTeam call") {
                    
                    let teamRequest = RGBYCCHAPI.DeleteTeam(id: 789).request
                    let teamRequestURLString = teamRequest.request?.URL?.absoluteString
                    
                    expect(teamRequestURLString).to(equal("http://api.rgbycch-rest.dev/teams/789.json"))
                }
                
                it("should be able to construct the url correctly for adding a player to a team call") {
                    
                    let teamRequest = RGBYCCHAPI.AddPlayerToTeam(teamId: 777, playerId: 123).request
                    let teamRequestURLString = teamRequest.request?.URL?.absoluteString
                    
                    expect(teamRequestURLString).to(equal("http://api.rgbycch-rest.dev/teams/777/add_player.json"))
                }
                
                it("should be able to construct the url correctly for removing a player from a team call") {
                    
                    let teamRequest = RGBYCCHAPI.RemovePlayerFromTeam(teamId: 777, playerId: 123).request
                    let teamRequestURLString = teamRequest.request?.URL?.absoluteString
                    
                    expect(teamRequestURLString).to(equal("http://api.rgbycch-rest.dev/teams/777/remove_player.json"))
                }
                
                it("should be able to execute a request to get a team") {
                    
                    let expectation = self.expectationWithDescription("GetTeamByIdCompletion")
                    
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.GetTeamById(id: 123), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should be able to execute a request to get a list of teams by id") {
                    
                    let expectation = self.expectationWithDescription("GetTeamsByIdsCompletion")
                    
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.GetTeamsByIds(ids: [123, 456]), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should be able to execute a request to search for a list of teams by keyword") {
                    
                    let expectation = self.expectationWithDescription("SearchTeamsByKeywordCompletion")
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.SearchTeamsByKeyword(keyword: "und"), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should be able to execute a request to create a new team") {
                    
                    let expectation = self.expectationWithDescription("CreateTeamCompletion")
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.CreateTeam(title: "Team Title", clubId: 123), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should return one team when creating a new team") {
                    
                    let expectation = self.expectationWithDescription("CreateTeamCompletion")
                    
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.CreateTeam(title: "Team Title", clubId: 123), completionBlock: { (results) -> Void in
                            if let teams = results as? [Team] {
                                XCTAssert(teams.count == 1)
                                let team = teams[0]
                                expect(team.identifier).to(equal(1))
                                expect(team.title).to(equal("International U21 Team"))
                                expectation.fulfill()
                            } else {
                                XCTFail("api call failed")
                            }
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should be able to execute a request to update an existing team") {
                    
                    let expectation = self.expectationWithDescription("UpdateTeamCompletion")
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.UpdateTeam(id: 456, title: "Updated Title", clubId: 123), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should be able to execute a request to add a player to an existing team") {
                    
                    let expectation = self.expectationWithDescription("UpdateTeamAddPlayerCompletion")
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.AddPlayerToTeam(teamId: 777, playerId: 123), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should be able to execute a request to remove a player from an existing team") {
                    
                    let expectation = self.expectationWithDescription("UpdateTeamRemovePlayerCompletion")
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.RemovePlayerFromTeam(teamId: 777, playerId: 123), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should return one team when updating a team") {
                    
                    let expectation = self.expectationWithDescription("UpdateTeamCompletion")
                    
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.UpdateTeam(id: 456, title: "Updated Title", clubId: 123), completionBlock: { (results) -> Void in
                            if let teams = results as? [Team] {
                                XCTAssert(teams.count == 1)
                                expectation.fulfill()
                            } else {
                                XCTFail("api call failed")
                            }
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should be able to execute a request to delete an existing team") {
                    
                    let expectation = self.expectationWithDescription("DeleteTeamCompletion")
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.DeleteTeam(id: 789), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
            }
            
            context("Testing Player API calls") {
                
                it("should be able to construct the url correctly for a GetPlayerById call") {
                    
                    let playerRequest = RGBYCCHAPI.GetPlayerById(id: 123).request
                    let playerRequestURLString = playerRequest.request?.URL?.absoluteString
                    
                    expect(playerRequestURLString).to(equal("http://api.rgbycch-rest.dev/players/123.json"))
                }
                
                it("should be able to construct the url correctly for a GetPlayersByIds call") {

                    let playerRequest = RGBYCCHAPI.GetPlayersByIds(ids: [123, 456]).request
                    let playerRequestURLString = playerRequest.request?.URL?.absoluteString
                    
                    expect(playerRequestURLString).to(equal("http://api.rgbycch-rest.dev/players?player_ids=123%2C456"))
                }
                
                it("should be able to construct the url correctly for a SearchPlayersByKeyword call") {
                    
                    let playerRequest = RGBYCCHAPI.SearchPlayersByKeyword(keyword: "rugg").request
                    let playerRequestURLString = playerRequest.request?.URL?.absoluteString
                    
                    expect(playerRequestURLString).to(equal("http://api.rgbycch-rest.dev/players?keyword=rugg"))
                }
                
                it("should be able to construct the url correctly for a CreatePlayer call") {
                    
                    let playerRequest = RGBYCCHAPI.CreatePlayer(firstName: "a", lastName: "b", nickName: "c", dob: NSDate(), email: "e", phoneNumber: "f").request
                    let playerRequestURLString = playerRequest.request?.URL?.absoluteString
                    
                    expect(playerRequestURLString).to(equal("http://api.rgbycch-rest.dev/players.json"))
                }
                
                it("should be able to construct the url correctly for a UpdatePlayer call") {
                    
                    let playerRequest = RGBYCCHAPI.UpdatePlayer(id: 456, firstName: "a", lastName: "b", nickName: "c", dob: NSDate(), email: "e", phoneNumber: "f").request
                    let playerRequestURLString = playerRequest.request?.URL?.absoluteString
                    
                    expect(playerRequestURLString).to(equal("http://api.rgbycch-rest.dev/players/456.json"))
                }
                
                it("should be able to construct the url correctly for a DeletePlayer call") {
                    
                    let playerRequest = RGBYCCHAPI.DeletePlayer(id: 789).request
                    let playerRequestURLString = playerRequest.request?.URL?.absoluteString
                    
                    expect(playerRequestURLString).to(equal("http://api.rgbycch-rest.dev/players/789.json"))
                }
                
                it("should be able to execute a request to get a player") {
                    
                    let expectation = self.expectationWithDescription("GetPlayerByIdCompletion")

                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.GetPlayerById(id: 123), completionBlock: { (results) -> Void in
                                expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should be able to execute a request to get a list of players by id") {
                    
                    let expectation = self.expectationWithDescription("GetPlayersByIdsCompletion")
                    
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.GetPlayersByIds(ids: [123, 456]), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should be able to execute a request to search for a list of players by keyword") {
                
                    let expectation = self.expectationWithDescription("SearchPlayersByIdsCompletion")
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.SearchPlayersByKeyword(keyword: "rugg"), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should be able to execute a request to create a new player") {
                    
                    let expectation = self.expectationWithDescription("CreatePlayerCompletion")
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.CreatePlayer(firstName: "a", lastName: "b", nickName: "c", dob: NSDate(), email: "e", phoneNumber: "f"), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should be able to execute a request to update an existing player") {
                    
                    let expectation = self.expectationWithDescription("UpdatePlayerCompletion")
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.UpdatePlayer(id: 456, firstName: "a", lastName: "b", nickName: "c", dob: NSDate(), email: "e", phoneNumber: "f"), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should be able to execute a request to update only certain attributes on an existing player") {

                    let expectation = self.expectationWithDescription("UpdatePlayerCompletion")
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.UpdatePlayer(id: 456, firstName: "a", lastName: nil, nickName: nil, dob: nil, email: "", phoneNumber: nil), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should be able to execute a request to delete an existing player") {
                    
                    let expectation = self.expectationWithDescription("DeletePlayerCompletion")
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.DeletePlayer(id: 789), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should return one player for a get player by id request after parsing") {
                    
                    let expectation = self.expectationWithDescription("GetPlayerCompletion")
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.GetPlayerById(id: 123), completionBlock: { (results) -> Void in
                            if let players = results as? [Player] {
                                let player:Player = players[0]
                                expect(player.identifier).to(equal(1))
                                expect(player.firstName).to(equal("Blanda"))
                                expect(player.lastName).to(equal("Kutch"))
                                expect(player.nickName).to(equal("Gerry"))
                                expect(player.email).to(equal("adonis@brakus.com"))
                                expect(player.phoneNumber).to(equal("123456789"))
                                expectation.fulfill()
                            } else {
                                XCTFail("api call failed")
                            }
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should return two players when searching by multiple ids") {
                    
                    let expectation = self.expectationWithDescription("GetPlayersByIdsCompletion")
                    
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.GetPlayersByIds(ids: [123, 456]), completionBlock: { (results) -> Void in
                            if let players = results as? [Player] {
                                XCTAssert(players.count == 2)
                                expectation.fulfill()
                            } else {
                                XCTFail("api call failed")
                            }
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should return one player when searching by keyword") {
                    
                    let expectation = self.expectationWithDescription("SearchPlayersByKeywordCompletion")
                    
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.SearchPlayersByKeyword(keyword: "rugg"), completionBlock: { (results) -> Void in
                            if let players = results as? [Player] {
                                XCTAssert(players.count == 1)
                                expectation.fulfill()
                            } else {
                                XCTFail("api call failed")
                            }
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should return one player when creating a new player") {
                    
                    let expectation = self.expectationWithDescription("CreatePlayerCompletion")
                    
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.CreatePlayer(firstName: "a", lastName: "b", nickName: "c", dob: NSDate(), email: "e", phoneNumber: "f"), completionBlock: { (results) -> Void in
                            if let players = results as? [Player] {
                                XCTAssert(players.count == 1)
                                expectation.fulfill()
                            } else {
                                XCTFail("api call failed")
                            }
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should return one player when updating a player") {
                    
                    let expectation = self.expectationWithDescription("UpdatePlayerCompletion")
                    
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.UpdatePlayer(id: 456, firstName: "a", lastName: "b", nickName: "c", dob: NSDate(), email: "e", phoneNumber: "f"), completionBlock: { (results) -> Void in
                            if let players = results as? [Player] {
                                XCTAssert(players.count == 1)
                                expectation.fulfill()
                            } else {
                                XCTFail("api call failed")
                            }
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
            }
            
            context("Testing Clubs API calls") {
                
                it("should be able to construct the url correctly for a GetClubById call") {
                    
                    let clubRequest = RGBYCCHAPI.GetClubById(id: 123).request
                    let clubRequestURLString = clubRequest.request?.URL?.absoluteString
                    
                    expect(clubRequestURLString).to(equal("http://api.rgbycch-rest.dev/clubs/123.json"))
                }
                
                it("should be able to construct the url correctly for a GetPlayersByIds call") {
                    
                    let clubRequest = RGBYCCHAPI.GetClubsByIds(ids: [123, 456]).request
                    let clubRequestURLString = clubRequest.request?.URL?.absoluteString
                    
                    expect(clubRequestURLString).to(equal("http://api.rgbycch-rest.dev/clubs?club_ids=123%2C456"))
                }
                
                it("should be able to construct the url correctly for a SearchClubsByKeyword call") {
                    
                    let clubRequest = RGBYCCHAPI.SearchClubsByKeyword(keyword: "clon").request
                    let clubRequestURLString = clubRequest.request?.URL?.absoluteString
                    
                    expect(clubRequestURLString).to(equal("http://api.rgbycch-rest.dev/clubs?keyword=clon"))
                }
                
                it("should be able to construct the url correctly for a CreateClub call") {
                    
                    let clubRequest = RGBYCCHAPI.CreateClub(title: "club title", url: "http://www.google.com", founded: NSDate()).request
                    let clubRequestURLString = clubRequest.request?.URL?.absoluteString
                    
                    expect(clubRequestURLString).to(equal("http://api.rgbycch-rest.dev/clubs.json"))
                }
                
                it("should be able to construct the url correctly for a UpdateClub call") {
                    
                    let clubRequest = RGBYCCHAPI.UpdateClub(id: 456, title: "Updated Title", url: "http://www.updated.com", founded:NSDate()).request
                    let clubRequestURLString = clubRequest.request?.URL?.absoluteString
                    
                    expect(clubRequestURLString).to(equal("http://api.rgbycch-rest.dev/clubs/456.json"))
                }
                
                it("should be able to construct the url correctly for a DeleteClub call") {
                    
                    let clubRequest = RGBYCCHAPI.DeleteClub(id: 789).request
                    let clubRequestURLString = clubRequest.request?.URL?.absoluteString
                    
                    expect(clubRequestURLString).to(equal("http://api.rgbycch-rest.dev/clubs/789.json"))
                }
                
                it("should be able to construct the url correctly for a AddTeamToClub API call") {
                    
                    let clubRequest = RGBYCCHAPI.AddTeamToClub(clubId: 777, teamId: 456).request
                    let clubRequestURLString = clubRequest.request?.URL?.absoluteString
                    
                    expect(clubRequestURLString).to(equal("http://api.rgbycch-rest.dev/clubs/777/add_team.json"))
                }
                
                it("should be able to construct the url correctly for a RemoveTeamFromClub API call") {
                    
                    let clubRequest = RGBYCCHAPI.RemoveTeamFromClub(clubId: 777, teamId: 456).request
                    let clubRequestURLString = clubRequest.request?.URL?.absoluteString
                    
                    expect(clubRequestURLString).to(equal("http://api.rgbycch-rest.dev/clubs/777/remove_team.json"))
                }
                
                it("should be able to execute a request to get a club") {
                    
                    let expectation = self.expectationWithDescription("GetClubByIdCompletion")
                    
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.GetClubById(id: 123), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should be able to execute a request to get a list of clubs by id") {
                    
                    let expectation = self.expectationWithDescription("GetClubsByIdsCompletion")
                    
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.GetClubsByIds(ids: [123, 456]), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should be able to execute a request to search for a list of clubs by keyword") {
                    
                    let expectation = self.expectationWithDescription("SearchClubsByKeywordCompletion")
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.SearchClubsByKeyword(keyword: "clon"), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should be able to execute a request to create a new club") {
                    
                    let expectation = self.expectationWithDescription("CreateClubCompletion")
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.CreateClub(title:"Club Title", url: "http://google.com", founded: NSDate()), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should be able to execute a request to update an existing club") {
                    
                    let expectation = self.expectationWithDescription("UpdateClubCompletion")
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.UpdateClub(id: 456, title:"Club Title", url: "http://google.com", founded: NSDate()), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should be able to execute a request to delete an existing club") {
                    
                    let expectation = self.expectationWithDescription("DeleteClubCompletion")
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.DeleteClub(id: 789), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should be able to execute a request to add a team to an existing club") {
                    
                    let expectation = self.expectationWithDescription("UpdateClubAddTeamCompletion")
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.AddTeamToClub(clubId: 777, teamId: 123), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should be able to execute a request to remove a team from an existing club") {
                    
                    let expectation = self.expectationWithDescription("UpdateClubRemoveTeamCompletion")
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.RemoveTeamFromClub(clubId: 777, teamId: 123), completionBlock: { (results) -> Void in
                            expectation.fulfill()
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should return one club for a get club by id request after parsing") {
                    
                    let expectation = self.expectationWithDescription("GetClubCompletion")
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.GetClubById(id: 123), completionBlock: { (results) -> Void in
                            if let clubs = results as? [Club] {
                                let club:Club = clubs[0]
                                expect(club.identifier).to(equal(123))
                                expect(club.title).to(equal("Club Title"))
                                expect(club.url).to(equal("http://google.com"))
                                expectation.fulfill()
                            } else {
                                XCTFail("api call failed")
                            }
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should return two clubs when searching by multiple ids") {
                    
                    let expectation = self.expectationWithDescription("GetClubsByIdsCompletion")
                    
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.GetClubsByIds(ids: [123, 456]), completionBlock: { (results) -> Void in
                            if let clubs = results as? [Club] {
                                XCTAssert(clubs.count == 2)
                                expectation.fulfill()
                            } else {
                                XCTFail("api call failed")
                            }
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should return one club when searching by keyword") {
                    
                    let expectation = self.expectationWithDescription("SearchClubsByKeywordCompletion")
                    
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.SearchClubsByKeyword(keyword: "clon"), completionBlock: { (results) -> Void in
                            if let clubs = results as? [Club] {
                                XCTAssert(clubs.count == 1)
                                expectation.fulfill()
                            } else {
                                XCTFail("api call failed")
                            }
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should return one club when creating a new club") {
                    
                    let expectation = self.expectationWithDescription("CreateClubCompletion")
                    
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.CreateClub(title: "Club Title", url: "http://google.com", founded: NSDate()), completionBlock: { (results) -> Void in
                            if let clubs = results as? [Club] {
                                XCTAssert(clubs.count == 1)
                                expectation.fulfill()
                            } else {
                                XCTFail("api call failed")
                            }
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should return one club when updating a club") {
                    
                    let expectation = self.expectationWithDescription("UpdateClubCompletion")
                    
                    do {
                        try RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.UpdateClub(id: 456, title:"Updated Title", url: "http://updated.com", founded:nil), completionBlock: { (results) -> Void in
                            if let clubs = results as? [Club] {
                                XCTAssert(clubs.count == 1)
                                expectation.fulfill()
                            } else {
                                XCTFail("api call failed")
                            }
                        })
                    } catch {
                        XCTFail("api call failed with error: \(error)")
                    }
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
            }
        }
    }
}

