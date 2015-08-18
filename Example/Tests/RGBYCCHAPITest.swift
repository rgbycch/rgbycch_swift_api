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

import rgbycch_swift_api

class RGBYCCHAPITest: QuickSpec {
    
    override func spec() {
        
        describe("RGBYCCHAPI") {
            
            context("Testing Player API calls") {
                
                it("should be able to construct the url correctly") {
                    
                    let playerRequest = RGBYCCHAPI.Player(id: "123").request
                    let playerRequestURLString = playerRequest.request.URL?.absoluteString
                    
                    expect(playerRequestURLString).to(equal("http://localhost:8080/rest/v1/player/123"))
                }
                
                it("should be able to execute a request to get a player") {
                    
                    let expectation = self.expectationWithDescription("GetPlayerCompletion")
                    
                    NSURLProtocol.registerClass(RGBYCCHAPINetworkInterceptor)
                    
                    let playerRequest = RGBYCCHAPI.Player(id: "123")

                    RGBYCCHAPIExecutor.sharedInstance.executeRequest(RGBYCCHAPI.Player(id: "123"), completionBlock: { (results, error) -> Void in
                        if error == nil {
                            expectation.fulfill()
                        }
                    })
                    
                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
            }
        }
    }
}

