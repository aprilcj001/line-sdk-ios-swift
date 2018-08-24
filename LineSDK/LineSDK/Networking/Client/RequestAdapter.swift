//
//  RequestAdapter.swift
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

import Foundation

/// Adapts a request to another one.
/// An adapter takes responsibility of modifying an input `URLRequest`.
public protocol RequestAdapter {
    
    /// Adapts an input `URLRequest` and return a new modified one.
    ///
    /// - Parameter request: Input request to be adapted.
    /// - Returns: A new request object with modification applied.
    /// - Throws: An error during adapting process.
    func adapted(_ request: URLRequest) throws -> URLRequest
}

struct TokenAdapter: RequestAdapter {
    let token: String?
    init(token: String?) {
        self.token = token
    }
    
    func adapted(_ request: URLRequest) throws -> URLRequest {
        guard let token = token else {
            throw SDKError.requestFailed(reason: .lackOfAccessToken)
        }
        var request = request
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        return request
    }
}

struct HeaderAdapter: RequestAdapter {
    static let `default` = HeaderAdapter()
    
    let userAgent: String
    
    init(in info: [String: Any]? = nil) {
        
        let info = info ?? Bundle.main.infoDictionary ?? [:]
        
        let appID = info["CFBundleIdentifier"] as? String ?? ""
        let appVersion = info["CFBundleShortVersionString"] as? String ?? ""
        
        let device = UIDevice.current
        let systemVersion = device.systemVersion.replacingOccurrences(of: ".", with: "_")
        let model = device.model
        
        userAgent = "\(appID)/\(appVersion) ChannelSDK/\(Constant.SDKVersion) (\(model); CPU iPhone OS \(systemVersion) like Mac OS X)"
    }
    
    func adapted(_ request: URLRequest) throws -> URLRequest {
        var request = request
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("private, no-store, no-cache, must-revalidate", forHTTPHeaderField: "Cache-Control")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        return request
    }
}

/// An easy way to create a `RequestAdapter` with a block.
public struct AnyRequestAdapter: RequestAdapter {

    var block: (URLRequest) throws -> URLRequest
    
    /// Initialize an `AnyRequestAdapter` with a execution closure.
    ///
    /// - Parameter block: A closure will be executed with an input `URLRequest`.
    public init(_ block: @escaping (URLRequest) throws -> URLRequest) {
        self.block = block
    }
    
    /// Adapts an input `URLRequest` and return a new modified one.
    ///
    /// - Parameter request: Input request to be adapted.
    /// - Returns: A new request object with modification applied.
    /// - Throws: An error during adapting process.
    /// - Note: This method just call the `block` passed in from the initializer.
    public func adapted(_ request: URLRequest) throws -> URLRequest {
        return try block(request)
    }
}
