//
//  OrpheeApi.swift
//  Orphee
//
//  Created by Jeromin Lebon on 13/11/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import Alamofire

class OrpheeApi {
    
    var url = "http://163.5.84.242:3000/api"
    
    func login(token: String, completion:(response: AnyObject) ->()){
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        print(token)
        Alamofire.request(.POST, "\(url)/login", headers: headers).responseJSON { request, response, json in
            if (response?.statusCode == 500){
                completion(response:"error")
            }
            else if(response?.statusCode == 401){
                completion(response:"wrong mdp")
            }
            else if (response?.statusCode == 200){
                print(json.value)
                if let user = json.value!["user"] as! Dictionary<String, AnyObject>?{
                    let user = User(User: user)
                    user.token = json.value!["token"] as! String
                    let data = NSKeyedArchiver.archivedDataWithRootObject(user)
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: "myUser")
                    SocketManager.sharedInstance.connectSocket()
                    completion(response:"ok")
                }
            }
        }
    }
    
    func register(pseudo: String, mail: String, password: String, completion:(response: AnyObject) -> ()){
        let param = [
            "name": "\(pseudo)",
            "username": "\(mail)",
            "password": "\(password)"
        ]
        Alamofire.request(.POST, "\(url)/register", parameters: param, encoding: .JSON).responseJSON { request, response, json in
            if (response?.statusCode == 500){
                completion(response: "error")
            }
            else if(response?.statusCode == 409){
                completion(response: "exists")
            }
            else if(response?.statusCode == 200){
                completion(response: "ok")
            }
        }
    }
    
    func lostPassword(mail: String, completion:(response: AnyObject) -> ()){
        let param = [
            "username":"\(mail)"
        ]
        Alamofire.request(.POST, "\(url)/forgot", parameters: param, encoding: .JSON).responseJSON { request, response, json in
            if (response?.statusCode == 200){
                completion(response: "ok")
            }
        }
    }
    
    func like(id :String, token: String, completion:(response: AnyObject) ->()){
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request(.GET, "http://163.5.84.242:3000/api/like/\(id)", headers: headers).responseJSON{request, response, json in
            print(response)
            if (response?.statusCode == 200){
                print(json.value)
                completion(response: "ok")
            }
            if (response?.statusCode == 400){
                print(json.value)
                completion(response: "liked")
            }
        }
    }
    
    func dislike(id: String, token: String, completion:(response: AnyObject) ->()){
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request(.GET, "http://163.5.84.242:3000/api/dislike/\(id)", headers: headers).responseJSON{request, response, json in
            print(response)
            if (response?.statusCode == 200){
                print(json.value)
                completion(response: "ok")
            }
        }
    }
    
    func getPopularCreations(offset: Int, size: Int, completion:(creations: [Creation], users: [User]) -> ()){
        let url = "http://163.5.84.242:3000/api/creationPopular?offset=\(offset)&size=\(size)"
        var arrayCreation: [Creation] = []
        var arrayUser: [User] = []
        Alamofire.request(.GET, url).responseJSON{request, response, json in
            if (response?.statusCode == 200){
                if let array = json.value as! Array<Dictionary<String, AnyObject>>?{
                    for elem in array{
                        arrayCreation.append(Creation(Creation: elem))
                        arrayUser.append(User(User: elem["creator"]!.objectAtIndex(0) as! Dictionary<String, AnyObject>))
                    }
                    completion(creations: arrayCreation, users: arrayUser)
                }
                else{
                    // A REMPLIR
                }
            }
        }
    }
    
    func sendComment(token: String, name: String, picture: String, creationId: String, userId: String, message: String, completion:(response: AnyObject) -> ()){
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        let params = [
            "creation": "\(creationId)",
            "creator": "\(userId)",
            "message": "\(message)",
            "parentId": "\(creationId)"
        ]
        Alamofire.request(.POST, "\(url)/comment", headers: headers, parameters: params, encoding: .JSON).responseJSON{ request, response, json in
            print(json.value)
            if (response?.statusCode == 200){
                let commentToAdd = Comment(Comment: message,
                    user: name, picture: picture)
                completion(response: commentToAdd)
            }
        }
        
    }
    
    func getComments(creationId: String, completion:(response: [Comment]) -> ()){
        Alamofire.request(.GET, "\(url)/comment/creation/\(creationId)").responseJSON{request, response, json in
            print("comments = \(json.value)")
            if (response!.statusCode == 200){
                var arrayComments: [Comment] = []
                if let array = json.value as! Array<Dictionary<String, AnyObject>>?{
                    for elem in array{
                        var msg = ""
                        var pic = ""
                        var name = ""
                        if let message = elem["message"] as? String{
                            msg = message
                        }
                        if let picture = elem["creator"]!["picture"] as? String{
                            pic = picture
                        }
                        if let user = elem["creator"]!["name"] as? String{
                            name = user
                        }
                        arrayComments.append(Comment(Comment: msg, user: name, picture: pic))
                    }
                    completion(response: arrayComments)
                }
            }
        }
    }
    
    func getUsers(offset: Int, size: Int, completion:(response: [User]) ->()){
        Alamofire.request(.GET, "\(url)/user?offset=\(offset)&size=\(size)").responseJSON{request, response, json in
            print(json.value)
            if (response?.statusCode == 200){
                var arrayUser: [User] = []
                if let array = json.value as! Array<Dictionary<String, AnyObject>>?{
                    for elem in array{
                        arrayUser.append(User(User: elem))
                    }
                    completion(response: arrayUser)
                }
            }
        }
    }
    
    func addFriend(token: String, id: String, completion:(response: AnyObject) -> ()){
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request(.GET, "\(url)/askfriend/\(id)", headers: headers).responseJSON{
            request, response, json in
            if (response?.statusCode == 200){
                completion(response: "ok")
            }
            else if (response?.statusCode == 500){
                completion(response: "error")
            }
        }
    }
    
    func notify(token: String, creationId: String, completion:(response: AnyObject) -> ()){
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request(.GET, "\(url)/notify/comments/\(creationId)", headers: headers).responseJSON{request, response, json in
            if (response?.statusCode == 200){
                completion(response: "ok")
            }
        }
    }
    
    func sendImgToServer(token: String, id: String, completion:(response: AnyObject) -> ()) {
        Alamofire.request(.GET, "http://163.5.84.242:3000/api/upload/image/png").responseJSON{request, response, json in
            print(request)
            print(response)
            print(json.value!)
            if (response?.statusCode == 200){
                if let dic = json.value as! Dictionary<String, AnyObject>?{
                    let headers = [
                        "Content-Type":"image/png"
                    ]
                    let url = dic["urlPut"] as! String
                    let urlGet = dic["urlGet"] as! String
                    self.sendImgToAmazon(url, headers: headers, urlGet: urlGet, completion: {(response) in
                        if (response as! String == "ok"){
                            self.updateUserProfile(token, id: id, urlGet: urlGet, completion: {(response) in
                                completion(response: response)
                            })
                        }
                    })
                }
            }
        }
    }
    
    func sendImgToAmazon(url: String, headers: [String:String], urlGet: String, completion:(response: AnyObject) ->()){
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let destinationPath = documentsPath.stringByAppendingPathComponent("imgProfile.png")
        Alamofire.upload(.PUT, url, headers: headers, file: NSURL(fileURLWithPath: destinationPath))
            .responseJSON{ request, response, result in
                print(response)
                print(result.value)
                completion(response: "ok")
        }
    }
    
    func updateUserProfile(token: String, id: String, urlGet: String, completion:(response: AnyObject) -> ()){
        let parameter = [
            "picture":"\(urlGet)"
        ]
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request(.PUT, "\(url)/user/\(id)", headers: headers, parameters: parameter).responseJSON{request, response, json in
            print(response)
            print(json.value)
            if (response!.statusCode == 200){
                completion(response: urlGet)
            }
        }
    }
    
    func getFriends(id: String, completion:(response:AnyObject) -> ()){
        Alamofire.request(.GET, "\(url)/user/\(id)/friends").responseJSON{ request, response, json in
            print(response)
            if (response?.statusCode == 200){
                print(json.value)
                if let array = json.value as! Array<Dictionary<String, AnyObject>>?{
                    var arrayFriends: [User] = []
                    for elem in array{
                        arrayFriends.append(User(User: elem))
                        print(elem)
                    }
                    completion(response: arrayFriends)
                }
            }
        }
    }
    
    func getNews(id: String, token: String, completion:(response: AnyObject) -> ()){
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request(.GET, "\(url)/user/\(id)/news", headers: headers).responseJSON{ request, response, json in
            print(response)
            if (response?.statusCode == 200){
                print(json.value)
            }
        }
    }
    
    func removeFriend(id: String, token: String, completion:(response: AnyObject) -> ()){
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request(.GET, "\(url)/removeFriend/\(id)", headers: headers).responseJSON{ request, response, json in
            if (response?.statusCode == 200){
                print(json.value)
                completion(response: "ok")
            }
        }
    }
}