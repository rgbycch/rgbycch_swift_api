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
                let map = ["http://api.rgbycch-rest.dev/players/123.json" : "get_player_by_id.json",
                    "http://api.rgbycch-rest.dev/players?player_ids=123%2C456" : "get_players_by_ids.json",
                    "http://api.rgbycch-rest.dev/players?keyword=rugg" : "search_players.json"]
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
            
            context("Testing Player API calls") {
                
                it("should be able to construct the url correctly for a GetPlayerById call") {
                    
                    let playerRequest = RGBYCCHAPI.GetPlayerById(id: "123").request
                    let playerRequestURLString = playerRequest.request?.URL?.absoluteString
                    
                    expect(playerRequestURLString).to(equal("http://api.rgbycch-rest.dev/players/123.json"))
                }
                
                it("should be able to construct the url correctly for a GetPlayersByIds call") {

                    let playerRequest = RGBYCCHAPI.GetPlayersByIds(ids: ["123", "456"]).request
                    let playerRequestURLString = playerRequest.request?.URL?.absoluteString
                    
                    expect(playerRequestURLString).to(equal("http://api.rgbycch-rest.dev/players?player_ids=123%2C456"))
                }
                
                it("should be able to construct the url correctly for a SearchPlayersByKeyword call") {
                    
                    let playerRequest = RGBYCCHAPI.SearchPlayersByKeyword(keyword: "rugg").request
                    let playerRequestURLString = playerRequest.request?.URL?.absoluteString
                    
                    expect(playerRequestURLString).to(equal("http://api.rgbycch-rest.dev/players?keyword=rugg"))
                }
                
                it("should be able to execute a request to get a player") {
                    
                    let expectation = self.expectationWithDescription("GetPlayerByIdCompletion")

                    RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.GetPlayerById(id: "123"), completionBlock: { (results, error) -> Void in
                        if let error = error {
                            XCTFail("api call failed with error: \(error)")
                        } else {
                            expectation.fulfill()
                        }
                    })
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should be able to execute a request to get a list of players by id") {
                    
                    let expectation = self.expectationWithDescription("GetPlayersByIdsCompletion")
                    
                    RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.GetPlayersByIds(ids: ["123", "456"]), completionBlock: { (results, error) -> Void in
                        if let error = error {
                            XCTFail("api call failed with error: \(error)")
                        } else {
                            expectation.fulfill()
                        }
                    })
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should be able to execute a request to search for a list of players by keyword") {
                
                    let expectation = self.expectationWithDescription("SearchPlayersByIdsCompletion")
                    
                    RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.SearchPlayersByKeyword(keyword: "rugg"), completionBlock: { (results, error) -> Void in
                        if let error = error {
                            XCTFail("api call failed with error: \(error)")
                        } else {
                            expectation.fulfill()
                        }
                    })
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should return one player for a get player by id request after parsing") {
                    
                    let expectation = self.expectationWithDescription("GetPlayerCompletion")
                    
                    RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.GetPlayerById(id: "123"), completionBlock: { (results, error) -> Void in
                        if let error = error {
                            XCTFail("api call failed with error: \(error)")
                        } else {
                            if let players = results as? [Player] {
                                let player:Player = players[0]
                                expect(player.identifier).to(equal(1))
                                expect(player.firstName).to(equal("Blanda"))
                                expect(player.lastName).to(equal("Kutch"))
                                expect(player.nickName).to(equal("Gerry"))
                                expect(player.dob).to(equal("2015-09-17T10:24:05.000Z"))
                                expect(player.email).to(equal("adonis@brakus.com"))
                                expect(player.phoneNumber).to(equal("123456789"))
                                expectation.fulfill()
                            } else {
                                XCTFail("api call failed with error: \(error)")                                
                            }
                        }
                    })
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should return two players when searching by multiple ids") {
                    
                    let expectation = self.expectationWithDescription("GetPlayersByIdsCompletion")
                    
                    RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.GetPlayersByIds(ids: ["123", "456"]), completionBlock: { (results, error) -> Void in
                        if let error = error {
                            XCTFail("api call failed with error: \(error)")
                        } else {
                            if let players = results as? [Player] {
                                XCTAssert(players.count == 2)
                                expectation.fulfill()
                            } else {
                                XCTFail("api call failed with error: \(error)")
                            }
                        }
                    })
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
                
                it("should one player when searching by keyword") {
                    
                    let expectation = self.expectationWithDescription("SearchPlayersByIdsCompletion")
                    
                    RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.SearchPlayersByKeyword(keyword: "rugg"), completionBlock: { (results, error) -> Void in
                        if let error = error {
                            XCTFail("api call failed with error: \(error)")
                        } else {
                            if let players = results as? [Player] {
                                XCTAssert(players.count == 1)
                                expectation.fulfill()
                            } else {
                                XCTFail("api call failed with error: \(error)")
                            }
                        }
                    })
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
            }
        }
    }
}

