//
//  eCreationRouter.swift
//  Orphee
//
//  Created by John Bobington on 26/11/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import Alamofire

enum eCreationRouter: URLRequestConvertible {
    static let baseURLString = "http://163.5.84.242:3000"
    static var OAuthToken: String?
    static var userID: String?

    case CreateCrea(String)
    case ReadCrea(String)
    case UpdateCrea(String, [String: AnyObject])
    case DestroyCrea(String)
    case GetStoreURL
    case StoreCrea(url: String)
    case RetrieveCrea(url: String)

    var method: Alamofire.Method {
        switch self {
        case .CreateCrea:
            return .POST
        case .ReadCrea:
            return .GET
        case .UpdateCrea:
            return .PUT
        case .DestroyCrea:
            return .DELETE
        case .GetStoreURL:
            return .GET
        case .StoreCrea:
            return .PUT
        case .RetrieveCrea:
            return .GET
        }
    }

    var path: String {
        switch self {
        case .CreateCrea:
            return "/api/creation"
        case .ReadCrea(let id):
            return "/api/creation/\(id)"
        case .UpdateCrea(let id, _):
            return "/api/creation/\(id)"
        case .DestroyCrea(let id):
            return "/api/creation/\(id)"
        case .GetStoreURL:
            return "api/upload/audio/x-midi"
        case .StoreCrea(let url):
            return url
        case .RetrieveCrea(let url):
            return url
        }
    }

    // MARK: URLRequestConvertible

    var URLRequest: NSMutableURLRequest {
        var mutableURLRequest: NSMutableURLRequest!

        switch self {
        case .StoreCrea(let url):
            mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
            mutableURLRequest.setValue("audio/x-midi", forHTTPHeaderField: "Content-Type")
        case .RetrieveCrea(let url):
            mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        default:
            let URL = NSURL(string: eCreationRouter.baseURLString)!
            mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))

            if let token = eCreationRouter.OAuthToken {
                mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        mutableURLRequest.HTTPMethod = method.rawValue

        switch self {
        case .CreateCrea(let name):
            let params = [
                    "name": name,
                    "creator": eCreationRouter.userID!
            ]
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: params).0
        case .UpdateCrea(_, let parameters):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
        case .StoreCrea(_):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0
        case .RetrieveCrea(_):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0
        default:
            return mutableURLRequest
        }
    }
}
