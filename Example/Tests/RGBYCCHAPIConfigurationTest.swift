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

class RGBYCCHAPIConfigurationTest: QuickSpec {
    
    override func spec() {
        
        describe("RGBYCCHAPIConfiguration") {

            context("RGBYCCHAPIConfiguration Configuration Tests") {
                
                it("should understand whether or not it is running the unit tests") {
                    expect(RGBYCCHAPIConfiguration.sharedState.isRunningUnitTests) == true
                }
                
                it("should know when to target the local server") {
                    
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "RGBYCCHAPIConfigurationUseLocalServerKey")
                    
                    expect(RGBYCCHAPIConfiguration.sharedState.useLocalServer) == true
                }
                
                it("should know when to target the remote server") {
                    
                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: "RGBYCCHAPIConfigurationUseLocalServerKey")
                    
                    expect(RGBYCCHAPIConfiguration.sharedState.useLocalServer) == false
                }
                
                it("should know to use v1 of the API service by default") {
                    
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "RGBYCCHAPIConfigurationAPIVersion")
                    
                    expect(RGBYCCHAPIConfiguration.sharedState.apiVersion) == "1"
                }
                
                it("should know if the client has specified a different version of the API service") {

                    NSUserDefaults.standardUserDefaults().setObject("2.2", forKey: "RGBYCCHAPIConfigurationAPIVersion")
                    
                    expect(RGBYCCHAPIConfiguration.sharedState.apiVersion) == "2.2"
                }
            }
        }
    }
}
