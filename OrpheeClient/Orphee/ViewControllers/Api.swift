//
//  Api.swift
//  Orphee
//
//  Created by Jeromin Lebon on 03/08/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public enum Route: String {
    case LOGIN, REGISTER
}

class API{
    let headers: Dictionary<String, String>
    let params: Dictionary<String, String>
    let method: Alamofire.Method
    let url: String
    var dicResponse: Dictionary<String, JSON>
    
    required init(url: String, method: Alamofire.Method, params: Dictionary<String, String> = Dictionary<String, String>(), headers: Dictionary<String, String> = Dictionary<String, String>()){
        self.headers = headers
        self.params = params
        self.method = method
        self.url = url
        self.dicResponse = ["":""]
    }
    
    func request(completionHandler: (Dictionary<String, JSON>) -> ()) -> (){
        Alamofire.request(self.method, self.url, parameters: self.params, headers: self.headers, encoding: .JSON)
            .responseJSON { request, response, json in
                print(request)
                print(response)
                print(json)
                self.dicResponse["statusCode"] = JSON((response?.statusCode)!)
                self.dicResponse["json"] = JSON(json.value!)
                completionHandler(self.dicResponse)
        }
    }
}


public func requestOrpheeApi(method: Route, param: Dictionary<String, String> = Dictionary<String, String>(), headers: Dictionary<String, String> = Dictionary<String, String>()) -> Dictionary<String, JSON>{
    var url: String
    switch method{
    case .LOGIN:
        url = "http://163.5.84.242:3000/api/login"
        break
    case .REGISTER:
        url = "http://163.5.84.242:3000/api/register"
        break
    }
    let api = API(url: url, method: .POST, params: param, headers: headers)
    api.request{ (dic) in
        print(dic)
    }
    return ["":""]
}
