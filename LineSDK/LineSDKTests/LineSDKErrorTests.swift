//
//  SDKErrorTests.swift
//
//  Copyright (c) 2016-present, LINE Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LINE Corporation.
//
//  As with any software that integrates with the LINE Corporation platform, your use of this software
//  is subject to the LINE Developers Agreement [http://terms2.line.me/LINE_Developers_Agreement].
//  This copyright notice shall be included in all copies or substantial portions of the software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import XCTest
@testable import LineSDK

class SDKErrorTests: XCTestCase {
    
    func testErrorClassifying() {
        let requestError = SDKError.requestFailed(reason: .missingURL)
        XCTAssertTrue(requestError.isRequestError)
        XCTAssertFalse(requestError.isResponseError)
        
        let responseError = SDKError.responseFailed(reason: .nonHTTPURLResponse)
        XCTAssertTrue(responseError.isResponseError)
        XCTAssertFalse(responseError.isAuthorizeError)
        
        let authError = SDKError.authorizeFailed(reason: .exhaustedLoginFlow)
        XCTAssertTrue(authError.isAuthorizeError)
        XCTAssertFalse(authError.isGeneralError)
        
        let generalError = SDKError.generalError(reason: .conversionError(string: "123", encoding: .utf8))
        XCTAssertTrue(generalError.isGeneralError)
        XCTAssertFalse(generalError.isRequestError)
        
    }
    
    func testUserCancelError() {
        let userCancelled = SDKError.authorizeFailed(reason: .userCancelled)
        let otherError = SDKError.authorizeFailed(reason: .exhaustedLoginFlow)
        
        XCTAssertTrue(userCancelled.isUserCancelled)
        XCTAssertFalse(otherError.isUserCancelled)
    }
    
    func testIsResponseError() {
        let err = APIError(InternalAPIError(message: "321"))
        let error = SDKError.responseFailed(reason: .invalidHTTPStatusAPIError(code: 123, error: err, raw: "raw"))
        XCTAssertTrue(error.isResponseError(statusCode: 123))
        XCTAssertFalse(error.isResponseError(statusCode: 321))
    }
    
    func testIsBadRequest() {
        let err = APIError(InternalAPIError(message: "Bad request"))
        let error = SDKError.responseFailed(reason: .invalidHTTPStatusAPIError(code: 400, error: err, raw: "raw"))
        XCTAssertTrue(error.isBadRequest)
    }
    
    func testIsPermission() {
        let err = APIError(InternalAPIError(message: "Not enough permission"))
        let error = SDKError.responseFailed(reason: .invalidHTTPStatusAPIError(code: 403, error: err, raw: "raw"))
        XCTAssertTrue(error.isPermissionError)
    }
}
