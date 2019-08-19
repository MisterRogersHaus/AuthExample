//
//  AuthManager.swift
//  WebrootAuth
//
//  Created by Mike Ross on 8/15/19.
//  Copyright © 2019 Mike Ross. All rights reserved.
//

import SwiftUI
import Foundation
import Alamofire
import Combine

// Our root auth URL components.
// Ugly, but fine for quick and dirty
let authScheme  = "https"
let authHost    = "identitytoolkit.googleapis.com"
let authKey     = "REPLACE_WITH_YOUR_AUTH_KEY"

// Simple user struct. This is observable.
// We obviously wouldn't use this approach with a legit app
final class UserData: ObservableObject {
    // BindableObject -> ObservableObject
    // @Published will synth objectWillChange and willSet per @Published var
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var message: String = ""
}

// I'm wrapping up the JSON Firebase auth calls in a singleton auth manager
// While there are very few situations that a singleton should be used, I believe this is a valid one.
// My preferred Swift singleton pattern is used, as it's save and allows for more initialization
class AuthManager {
    private static var sharedAuthManager: AuthManager = {
        let authManager = AuthManager()
        // Additional initialization can be used here.
        return authManager
    }()
    
    class func shared() -> AuthManager {
        return sharedAuthManager
    }

    var alamofireManager: Alamofire.SessionManager

    private init () {
        let configuration = URLSessionConfiguration.default
        alamofireManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    deinit {
    }

    func signUp(_ email: String, password: String, completionHandler: @escaping (Bool, String?) -> Void) {
        let parameters:[String: Any] = [
            "email": email,
            "password": password,
            "returnSecureToken": "true"
        ]
            
        var reason = ""
        alamofireManager.request(AuthRouter.signUp(parameters))
            .responseJSON { (response ) in
                guard response.result.isSuccess else {
                    if let error = response.result.error {
                        print("signUp() :.failure returned in .resonseJSON error= \(error)")
                        print("-----------------DATA-------------------------")
                        reason = "Error returned from Server. Error = \(error)"
                        completionHandler(false, reason)
                        return
                    } else {
                        completionHandler(false, "No error code: Failed to Signup")
                    }
                    return
                }
                if let json = response.result.value as? [String:Any] {
                    // Let's return our results.
                    reason = json.debugDescription
                    print(json)
                    completionHandler(json["email"] != nil ? true : false, reason)
                    return
                }
                completionHandler(false, "Unknown error: Returned success but with no result value")
                return
        }
    }
    
    func signIn(_ email: String, password: String, completionHandler: @escaping (Bool, String?) -> Void) {
        let parameters:[String: Any] = [
            "email": email,
            "password": password,
            "returnSecureToken": "true"
        ]

        var reason = ""
        alamofireManager.request(AuthRouter.signIn(parameters))
            .responseJSON { response in
                guard response.result.isSuccess else {
                    if let error = response.result.error {
                        print("signIn() :.failure returned in .resonseJSON error= \(error)")
                        print("-----------------DATA-------------------------")
                        reason = "Error returned from Server. Error = \(error)"
                        completionHandler(false, reason)
                    } else {
                        completionHandler(false, "No error code: Failed to Signin")
                    }
                    return
                }
                    
                if let json = response.result.value as? [String:Any] {
                    // Let's dump our results
                    reason = json.debugDescription
                    print(json)
                    completionHandler(json["error"] == nil ? true : false, reason)
                    return
                }
                completionHandler(false, "Unknown error: Returned success but with no result value")
                return
        }
    }
}

// I prefer to wrap up our endpoints in an enum; wish other languages had such powerful enums
enum AuthRouter: URLRequestConvertible {
    case signIn([String: Any])
    case signOut(Void)
    case signUp([String: Any])
    
    func asURLRequest() throws -> URLRequest {
        var method: HTTPMethod {
            switch self {
            // Our posts go here
            case .signIn,
                 .signOut,
                 .signUp:
                 return .post
            // Our gets would go here
            }
        }
        
        let result: (path: String?, parameters: [String: Any]?, queryItems: [URLQueryItem]?) = {
            // Our Firebase auth key.
            var queryItems = [URLQueryItem]()
            queryItems.append(URLQueryItem(name: "key", value: authKey))
            
            switch self {
                case .signUp(let params):
                    return ("/v1/accounts:signUp", params, queryItems)
                case .signIn(let params):
                    return ("/v1/accounts:signInWithPassword", params, queryItems)
                case .signOut:
                    return (nil, nil, nil)
            }
        } ()
        
        var urlComponents = URLComponents()
        urlComponents.scheme    = authScheme
        urlComponents.host      = authHost

        var encodedRequest: URLRequest? = nil
        
        // Since Firebase auth doesn't expose a signout API, I've written this to allow for a nil path, indicating
        // essentially a noop
        if let path = result.path {
            urlComponents.path = path
            
            if let queryItems = result.queryItems {
                urlComponents.queryItems = queryItems
            }
            let url = urlComponents.url
            
            var urlRequest          = URLRequest(url: url!)
            urlRequest.httpMethod   = method.rawValue
            
            let encoding            = JSONEncoding.default
            encodedRequest          = try encoding.encode(urlRequest, with: result.parameters)
            
            print(encodedRequest ?? "Nil Encoded Request")
        }
        
        return encodedRequest!
    }
}
