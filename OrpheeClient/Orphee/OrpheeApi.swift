//
//  OrpheeApi.swift
//  Orphee
//
//  Created by Jeromin Lebon on 13/11/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import Alamofire
import FileManagement
import ReactiveCocoa
import Haneke

class OrpheeApi {
    
    var url = "http://163.5.84.242:3000/api"
    
    func login(token: String, completion:(user: AnyObject) ->()){
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request(.POST, "\(url)/login", headers: headers).responseJSON { request, response, json in
            if (response?.statusCode == 500){
                completion(user:"error")
            }
            else if(response?.statusCode == 401){
                completion(user: "mdp")
            }
            else if (response?.statusCode == 200){
                print(json.value)
                if let result = json.value!["user"]{
                    do {
                        var user = try User.decode(result)
                        user.token = json.value!["token"] as? String
                        completion(user: "ok")
                    } catch let error {
                        print(error)
                        completion(user: "error")
                    }
                }
                completion(user: "ok")
            }
        }
    }
    
    func loginByGoogle(token: String, completion:(response: AnyObject) -> ()){
        let params = [
            "code":"\(token)",
            "clientId":"1091784243585-a16tac0tegj6vh5mibln1s3m1qjia72a.apps.googleusercontent.com",
            "redirectUri":"com.orphee.ios:/google"
        ]
        Alamofire.request(.POST, "http://163.5.84.242:3000/auth/google", parameters: params, encoding: .JSON).responseJSON { request, response, json in
            print(response)
            print(json.value)
            if (response?.statusCode == 500){
                completion(response: "error")
            }
            if (response?.statusCode == 200){
                if let result = json.value{
                    let user = result["user"]
                    print(user)
                    let userTmp : AnyObject = user
                    NSUserDefaults().setObject(userTmp, forKey: "myUser")
                    let token = result["token"]
                    NSUserDefaults().setObject(token, forKey: "myToken")
                }
            }
        }
    }
    //
    //    func register(pseudo: String, mail: String, password: String, completion:(response: AnyObject) -> ()){
    //        let param = [
    //            "name": "\(pseudo)",
    //            "username": "\(mail)",
    //            "password": "\(password)"
    //        ]
    //        Alamofire.request(.POST, "\(url)/register", parameters: param, encoding: .JSON).responseJSON { request, response, json in
    //            if (response?.statusCode == 500){
    //                completion(response: "error")
    //            }
    //            else if(response?.statusCode == 409){
    //                completion(response: "exists")
    //            }
    //            else if(response?.statusCode == 200){
    //                completion(response: "ok")
    //            }
    //        }
    //    }
    //
    //    func lostPassword(mail: String, completion:(response: AnyObject) -> ()){
    //        let param = [
    //            "username":"\(mail)"
    //        ]
    //        Alamofire.request(.POST, "\(url)/forgot", parameters: param, encoding: .JSON).responseJSON { request, response, json in
    //            if (response?.statusCode == 200){
    //                completion(response: "ok")
    //            }
    //        }
    //    }
    //
    
    
    func like(id :String, token: String, completion:(response: AnyObject) ->()){
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request(.GET, "http://163.5.84.242:3000/api/like/\(id)", headers: headers).responseJSON{request, response, json in
            if (response?.statusCode == 200){
                completion(response: "liked")
            }
            if (response?.statusCode == 400){
                self.dislike(id, token: token, completion: { (response) in
                    print(response)
                })
                completion(response: "disliked")
            }
        }
    }
    
    func dislike(id: String, token: String, completion:(response: AnyObject) ->()){
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request(.GET, "http://163.5.84.242:3000/api/dislike/\(id)", headers: headers).responseJSON{request, response, json in
            if (response?.statusCode == 200){
                completion(response: "disliked")
            }
        }
    }
    
    
    func getPopularCreations(offset: Int, size: Int, completion:(creations: [Creation]) -> ()){
        let url = "http://163.5.84.242:3000/api/creationPopular?offset=\(offset)&size=\(size)"
        var arrayCreation: [Creation] = []
        Alamofire.request(.GET, url).responseJSON{request, response, json in
            if (response?.statusCode == 200){
                if let array = json.value as! Array<Dictionary<String, AnyObject>>?{
                    for elem in array{
                        do {
                            let creation = try Creation.decode(elem)
                            arrayCreation.append(creation)
                        } catch let error {
                            print(error)
                            completion(creations: arrayCreation)
                        }
                    }
                    completion(creations: arrayCreation)
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
                print("comment ok")
//                let commentToAdd = Comment(Comment: message,
//                    user: name, picture: picture)
//                completion(response: commentToAdd)
            }
        }
        
    }
    
    
    func getComments(creationId: String, completion:(response: [AnyObject]) -> ()){
        Alamofire.request(.GET, "\(url)/comment/creation/\(creationId)").responseJSON{request, response, json in
            if (response == nil){
                self.fetchFromCache((request?.URLString)!, completion: { (cachedArray) in
                    completion(response: cachedArray.array)
                })
            }
            if let _ = json.value as! Array<Dictionary<String, AnyObject>>?{
                self.fetchFromCache((request?.URLString)!, completion: { (cachedArray) in
                    completion(response: cachedArray.array)
                })
            }
        }
    }
    
    
    func getInfoUserById(id: String, completion:(infoUser: [AnyObject]) -> ()){
        Alamofire.request(.GET, "\(url)/user/\(id)/creation").responseJSON{request, response, json in
            if (response == nil){
                self.fetchFromCache((request?.URLString)!, completion: { (cachedArray) in
                    completion(infoUser: cachedArray.array)
                })
            }
            if (response?.statusCode == 200){
                if let _ = json.value as! Array<Dictionary<String, AnyObject>>?{
                    self.fetchFromCache((request?.URLString)!, completion: { (cachedArray) in
                        completion(infoUser: cachedArray.array)
                    })
                }
            }
        }
    }
    
    func getUsers(offset: Int, size: Int, completion:(users: [AnyObject]) ->()){
        Alamofire.request(.GET, "\(url)/user?offset=\(offset)&size=\(size)").responseJSON{request, response, json in
            print((request?.URLString)!)
            if (response == nil){
                self.fetchFromCache((request?.URLString)!, completion: { (cachedArray) in
                    completion(users: cachedArray.array)
                })
            }
            if (response?.statusCode == 200){
                if let _ = json.value as! Array<Dictionary<String, AnyObject>>?{
                    self.fetchFromCache((request?.URLString)!, completion: { (cachedArray) in
                        completion(users: cachedArray.array)
                    })
                }
            }
        }
    }
    //
    //    func addFriend(token: String, id: String, completion:(response: AnyObject) -> ()){
    //        let headers = [
    //            "Authorization": "Bearer \(token)"
    //        ]
    //        Alamofire.request(.GET, "\(url)/askfriend/\(id)", headers: headers).responseJSON{
    //            request, response, json in
    //            if (response?.statusCode == 200){
    //                completion(response: "ok")
    //            }
    //            else if (response?.statusCode == 500){
    //                completion(response: "error")
    //            }
    //        }
    //    }
    //
    //    func notify(token: String, creationId: String, completion:(response: AnyObject) -> ()){
    //        let headers = [
    //            "Authorization": "Bearer \(token)"
    //        ]
    //        Alamofire.request(.GET, "\(url)/notify/comments/\(creationId)", headers: headers).responseJSON{request, response, json in
    //            if (response?.statusCode == 200){
    //                completion(response: "ok")
    //            }
    //        }
    //    }
    //
    //    func sendImgToServer(token: String, id: String, completion:(response: AnyObject) -> ()) {
    //        Alamofire.request(.GET, "http://163.5.84.242:3000/api/upload/image/png").responseJSON{request, response, json in
    //            print(request)
    //            print(response)
    //            print(json.value!)
    //            if (response?.statusCode == 200){
    //                if let dic = json.value as! Dictionary<String, AnyObject>?{
    //                    let headers = [
    //                        "Content-Type":"image/png"
    //                    ]
    //                    let url = dic["urlPut"] as! String
    //                    let urlGet = dic["urlGet"] as! String
    //                    self.sendImgToAmazon(url, headers: headers, urlGet: urlGet, completion: {(response) in
    //                        if (response as! String == "ok"){
    //                            self.updateUserProfile(token, id: id, urlGet: urlGet, completion: {(response) in
    //                                completion(response: response)
    //                            })
    //                        }
    //                    })
    //                }
    //            }
    //        }
    //    }
    //
    //    func sendImgToAmazon(url: String, headers: [String:String], urlGet: String, completion:(response: AnyObject) ->()){
    //        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    //        let destinationPath = documentsPath.stringByAppendingPathComponent("imgProfile.png")
    //        Alamofire.upload(.PUT, url, headers: headers, file: NSURL(fileURLWithPath: destinationPath))
    //            .responseJSON{ request, response, result in
    //                print(response)
    //                print(result.value)
    //                completion(response: "ok")
    //        }
    //    }
    //
    //    func updateUserProfile(token: String, id: String, urlGet: String, completion:(response: AnyObject) -> ()){
    //        let parameter = [
    //            "picture":"\(urlGet)"
    //        ]
    //        let headers = [
    //            "Authorization": "Bearer \(token)"
    //        ]
    //        Alamofire.request(.PUT, "\(url)/user/\(id)", headers: headers, parameters: parameter).responseJSON{request, response, json in
    //            print(response)
    //            print(json.value)
    //            if (response!.statusCode == 200){
    //                completion(response: urlGet)
    //            }
    //        }
    //    }
    //
    //    func getFriends(id: String, completion:(response:AnyObject) -> ()){
    //        Alamofire.request(.GET, "\(url)/user/\(id)/friends").responseJSON{ request, response, json in
    //            print(response)
    //            if (response?.statusCode == 200){
    //                print(json.value)
    //                if let array = json.value as! Array<Dictionary<String, AnyObject>>?{
    //                    var arrayFriends: [User] = []
    //                    for elem in array{
    //                        arrayFriends.append(User(User: elem))
    //                        print(elem)
    //                    }
    //                    completion(response: arrayFriends)
    //                }
    //            }
    //        }
    //    }
    //
    //    func getNews(id: String, token: String, completion:(response: AnyObject) -> ()){
    //        let headers = [
    //            "Authorization": "Bearer \(token)"
    //        ]
    //        Alamofire.request(.GET, "\(url)/user/\(id)/news", headers: headers).responseJSON{ request, response, json in
    //            print(response)
    //            if (response?.statusCode == 200){
    //                print(json.value)
    //            }
    //        }
    //    }
    //
    //    func removeFriend(id: String, token: String, completion:(response: AnyObject) -> ()){
    //        let headers = [
    //            "Authorization": "Bearer \(token)"
    //        ]
    //        Alamofire.request(.GET, "\(url)/removeFriend/\(id)", headers: headers).responseJSON{ request, response, json in
    //            if (response?.statusCode == 200){
    //                print(json.value)
    //                completion(response: "ok")
    //            }
    //        }
    //    }
    //
    //    func sendCreationToServer(userId: String, name: String, completion:(response: AnyObject) -> ()) {
    //        Alamofire.request(eCreationRouter.GetStoreURL)
    //            .responseJSON{request, response, json in
    //                print(request)
    //                print(response)
    //                print(json.value!)
    //                if (response?.statusCode == 200){
    //                    if let dic = json.value as! Dictionary<String, AnyObject>?{
    //                        let url = dic["urlPut"] as! String
    //                        let urlGet = dic["urlGet"] as! String
    //                        self.sendCreationToAmazon(name, urlPost: url, urlGet: urlGet, completion: {(response) in
    //                            if (response as! String == "ok") {
    //                                self.createCreation(name, urlGet: urlGet, completion: completion)
    //                            }
    //                        })
    //                    }
    //                }
    //        }
    //    }
    //
    //    func createCreation(name: String, urlGet: String, completion: (response: AnyObject) -> () ) {
    //        Alamofire.request(eCreationRouter.CreateCrea(name))
    //            .responseJSON { request, response, json in
    //                if (response?.statusCode == 200) {
    //                    if let json = json.value as? [String : AnyObject] {
    //                        let crea = Creation(Creation: json)
    //                        self.updateCreation(crea.id, urlGet: urlGet, completion: {
    //                            (response) in
    //                            completion(response: response)
    //                        })
    //                    }
    //                }
    //        }
    //    }
    //
    //    func sendCreationToAmazon(creationName: String, urlPost: String, urlGet: String, completion:(response: AnyObject) ->()) {
    //        let fm = MIDIFileManager(name: creationName)
    //        Alamofire.upload(eCreationRouter.StoreCrea(url: urlPost), data: fm.reader.readAllData())
    //            .responseJSON{ request, response, result in
    //                print(response)
    //                print(result.value)
    //                completion(response: "ok")
    //        }
    //    }
    //
    //    func updateCreation(id: String, urlGet: String, completion:(response: AnyObject) -> ()) {
    //        Alamofire.request(eCreationRouter.UpdateCrea(id, ["url" : url]))
    //            .responseJSON { request, response, json in
    //                print(response)
    //                print(json.value)
    //                if (response!.statusCode == 200){
    //                    completion(response: urlGet)
    //                }
    //        }
    //    }
    //
    //    func getCreation(url: String, destination: String, completion:(String) -> ()) {
    //        let dest = Request.suggestedDownloadDestination()
    //        print(url)
    //        Alamofire.download(eCreationRouter.RetrieveCrea(url: url), destination: dest)
    //            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
    //                dispatch_async(dispatch_get_main_queue(), { () -> Void in
    //                    print(totalBytesRead)
    //                })
    //            }
    //            .responseJSON { request, response, json in
    //                if (response?.statusCode == 200) {
    //                    if let name = response?.suggestedFilename {
    //                        let urlDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
    //                        completion("\(urlDirectory.path!)/\(name)")
    //                    }
    //                }
    //        }
    //    }
    
    func fetchFromCache(url: String, completion:(cachedArray: JSON) -> ()){
        let cache = Shared.JSONCache
        let URL = NSURL(string: url)!
        
        cache.fetch(URL: URL).onSuccess { JSON in
            completion(cachedArray: JSON)
        }
    }
}
