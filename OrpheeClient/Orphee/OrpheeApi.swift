//
//  OrpheeApi.swift
//  Orphee
//
//  Created by Jeromin Lebon on 13/11/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import Haneke
import Alamofire
import RxSwift
import RxOptional
import NSObject_Rx
import Moya

import FileManagement

//import UIKit

class OrpheeApi: NSObject {

    var url = "http://163.5.84.242:3000/api"

    func login(token: String, completion:(user: AnyObject) ->()){
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request(.POST, "\(url)/login", headers: headers).responseJSON { res in
            let response = res.response
            let json = res.result
            if (response?.statusCode == 500){
                completion(user:"error")
            }
            else if(response?.statusCode == 401){
                completion(user: "mdp")
            }
            else if (response?.statusCode == 200){
                print(json.value)
                if let result = json.value,
                    let usr = result["user"],
                    let user = usr {
                    do {
                        let user = try mySuperUser.decode(user)
                        user.token = String(json.value!["token"])
                        saveUser(user)
                        SocketManager.sharedInstance.connectSocket()
                        self.goToMainPageConnected()
                    } catch let error {
                        print(error)
                        completion(user: "error")
                    }
                }
                completion(user: "ok")
            }
        }
    }

    func disconnect(id: String, completion:(disconnected: AnyObject) -> ()){
        Alamofire.request(.GET, "http://163.5.84.242:3000/api/deco/\(id)").responseJSON { res in
            let response = res.response
            completion(disconnected: "ok")
            if (response?.statusCode == 500){
                completion(disconnected: "error")
            }
            if (response?.statusCode == 200){
                completion(disconnected: "ok")
            }
        }

    }

    func loginByGoogle(name: String, email: String, id: String, picture: String, completion:(response: AnyObject) -> ()){
        let params = [
            "name":"\(name)",
            "email":"\(email)",
            "id":"\(id)",
            "picture":"\(picture)",
            "tokenIos":"\(getDeviceToken())"
        ]
        Alamofire.request(.POST, "http://163.5.84.242:3000/cradogoogle", parameters: params, encoding: .JSON).responseJSON { res in
            let response = res.response
            let json = res.result

            print(json.value)
            if (response?.statusCode == 500){
                completion(response: "error")
            }
            if (response?.statusCode == 200){
                if let result = json.value,
                    let usr = result["user"],
                    let user = usr {
                    do {
                        let monUser = try mySuperUser.decode(user)
                        monUser.token = String(result["token"])
                        saveUser(monUser)
                        SocketManager.sharedInstance.connectSocket()
                        self.goToMainPageConnected()
                    } catch let error {
                        print(error)
                    }
                }
            }
        }
    }

    func loginByFacebook(name: String, email: String, id: String, picture: String, completion:(response: AnyObject) -> ()){
        let params = [
            "name":"\(name)",
            "email":"\(email)",
            "id":"\(id)",
            "picture":"\(picture)",
            "tokenIos":"\(getDeviceToken)"
        ]
        Alamofire.request(.POST, "http://163.5.84.242:3000/iosFb", parameters: params, encoding: .JSON).responseJSON { res in
            let response = res.response
            let json = res.result

            print(response)
            print(json.value)
            if (response?.statusCode == 500){
                completion(response: "error")
            }
            if (response?.statusCode == 200){
                if let result = json.value,
                    let usr = result["user"],
                    let user = usr {
                    do {
                        let monUser = try mySuperUser.decode(user)
                        monUser.token = String(result["token"])
                        saveUser(monUser)
                        SocketManager.sharedInstance.connectSocket()
                        self.goToMainPageConnected()
                    } catch let error {
                        print(error)
                    }
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
        Alamofire.request(.POST, "\(url)/register", parameters: param, encoding: .JSON).responseJSON { res in
            let response = res.response
            let json = res.result

            print(json.value)
            if (response?.statusCode == 500){
                completion(response: "error")
            }
            else if(response?.statusCode == 409){
                completion(response: "exists")
            }
            else if(response?.statusCode == 200){
                if let result = json.value!["user"]{
                    do {
                        let user = try mySuperUser.decode(result!)
                        user.token = String(json.value!["token"])
                        saveUser(user)
                        SocketManager().connectSocket()
                        self.goToMainPageConnected()
                    } catch let error {
                        print(error)
                        completion(response: "error")
                    }
                }
                completion(response: "ok")
            }
        }
    }

    //        func lostPassword(mail: String, completion:(response: AnyObject) -> ()){
    //            let param = [
    //                "username":"\(mail)"
    //            ]
    //            Alamofire.request(.POST, "\(url)/forgot", parameters: param, encoding: .JSON).responseJSON { request, response, json in
    //                if (response?.statusCode == 200){
    //                    completion(response: "ok")
    //                }
    //            }
    //        }

    func like(id :String, token: String, completion:(response: AnyObject) ->()){
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request(.GET, "http://163.5.84.242:3000/api/like/\(id)", headers: headers).responseJSON{ res in
            let response = res.response
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
        Alamofire.request(.GET, "http://163.5.84.242:3000/api/dislike/\(id)", headers: headers).responseJSON{ res in
            let response = res.response
            if (response?.statusCode == 200){
                completion(response: "disliked")
            }
        }
    }


    func getPopularCreations(offset: Int, size: Int, completion:(creations: [AnyObject]) -> ()){
        let url = "http://163.5.84.242:3000/api/creationPopular?offset=\(offset)&size=\(size)"
        Alamofire.request(.GET, url).responseJSON{ res in
            let response = res.response
            let request = res.request
            let json = res.result

            if (response == nil){
                self.fetchFromCache((request?.URLString)!, completion: { (cachedArray) in
                    completion(creations: cachedArray.array)
                })
            }
            if (response?.statusCode == 200){
                if let _ = json.value as! Array<Dictionary<String, AnyObject>>?{
                    self.fetchFromCache((request?.URLString)!, completion: { (cachedArray) in
                        completion(creations: cachedArray.array)
                    })
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
        Alamofire.request(.POST, "\(url)/comment", headers: headers, parameters: params, encoding: .JSON).responseJSON{ res in
            let response = res.response
            let json = res.result

            print(String.init(data: res.request!.HTTPBody!, encoding: NSUTF8StringEncoding))
            print(json.value)
            print(response)
            if (response?.statusCode == 200){
                print(json.value)
                completion(response: json.value!)
            }
        }
    }


    func getComments(creationId: String, completion:(response: [AnyObject]) -> ()){
        Alamofire.request(.GET, "\(url)/comment/creation/\(creationId)").responseJSON{ res in
            let response = res.response
            let request = res.request
            let json = res.result

            if (response == nil){
                self.fetchFromCache((request?.URLString)!, completion: { (cachedArray) in
                    completion(response: cachedArray.array)
                })
            }
            if (response?.statusCode == 200){
                if let _ = json.value as! Array<Dictionary<String, AnyObject>>?{
                    self.fetchFromCache((request?.URLString)!, completion: { (cachedArray) in
                        completion(response: cachedArray.array)
                    })
                }
            }
        }
    }


    func getInfoUserById(id: String, completion:(infoUser: [AnyObject]) -> ()){
        Alamofire.request(.GET, "\(url)/user/\(id)/creation").responseJSON{ res in
            let response = res.response
            let request = res.request
            let json = res.result

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
        Alamofire.request(.GET, "\(url)/user?offset=\(offset)&size=\(size)").responseJSON{ res in
            let response = res.response
            let request = res.request
            let json = res.result


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

    func addFriend(token: String, id: String, completion:(response: AnyObject) -> ()){
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request(.GET, "\(url)/askfriend/\(id)", headers: headers).responseJSON{ res in
            let response = res.response

            if (response?.statusCode == 200){
                completion(response: "ok")
            }
            else if (response?.statusCode == 500){
                completion(response: "error")
            }
        }
    }
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

    func getFriends(id: String, completion:(response: [AnyObject]) -> ()){
        Alamofire.request(.GET, "\(url)/user/\(id)/friends").responseJSON{  res in
            let response = res.response
            let request = res.request
            let json = res.result

            if (response == nil){
                self.fetchFromCache((request?.URLString)!, completion: { (cachedArray) in
                    completion(response: cachedArray.array)
                })
            }
            if (response?.statusCode == 200){
                if let test = json.value as! Array<Dictionary<String, AnyObject>>?{
                    self.fetchFromCache((request?.URLString)!, completion: { (cachedArray) in
                        completion(response: test)
                    })
                }
            }
        }
    }

    func getNews(id: String, token: String, completion:(response: [AnyObject]) -> ()){
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request(.GET, "\(url)/user/\(id)/news", headers: headers).responseJSON{  res in
            let response = res.response
            let request = res.request
            let json = res.result

            print("my News : \(response)")
            if (response == nil){
                self.fetchFromCache((request?.URLString)!, completion: { (cachedArray) in
                    completion(response: cachedArray.array)
                })
            }
            if (response?.statusCode == 200){
                if let test = json.value as! Array<Dictionary<String, AnyObject>>?{
                    self.fetchFromCache((request?.URLString)!, completion: { (cachedArray) in
                        completion(response: test)
                    })
                }
            }
        }
    }

    func removeFriend(id: String, token: String, completion:(response: AnyObject) -> ()){
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request(.GET, "\(url)/removeFriend/\(id)", headers: headers).responseJSON{  res in
            let response = res.response
            let json = res.result

            if (response?.statusCode == 200){
                print(json.value)
                completion(response: "ok")
            }else{
                completion(response: "error")
            }
        }
    }

    func acceptFriend(id: String, token: String, completion:(response: String) -> ()){
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request(.GET, "\(url)/acceptfriend/\(id)", headers: headers).responseJSON{ res in
            let response = res.response
            let json = res.result

            if (response?.statusCode == 200){
                if (json.value as! String == "already friend"){
                    completion(response: "already friend")
                }
                else if (json.value as! String == "no friend invitation"){
                    completion(response: "no friend invitation")
                }
                else {
                    completion(response: "ok")
                }
            }else{
                completion(response: "error")
            }
        }
    }

    func getConversation(id: String, token: String, completion:(response :[AnyObject]) -> ()){
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request(.GET, "\(url)/room/privateMessage/\(id)", headers: headers).responseJSON{ res in
            let response = res.response
            let request = res.request
            let json = res.result

            if (response == nil){
                self.fetchFromCache((request?.URLString)!, completion: { (cachedArray) in
                    completion(response: cachedArray.array)
                })
            }
            if (response?.statusCode == 200){
                if let test = json.value as! Array<Dictionary<String, AnyObject>>?{
                    completion(response: test)
                    self.fetchFromCache((request?.URLString)!, completion: { (cachedArray) in
                        completion(response: test)
                    })
                }
            }
        }
    }

    func fetchFromCache(url: String, completion:(cachedArray: JSON) -> ()){
        let cache = Shared.JSONCache
        let URL = NSURL(string: url)!

        cache.fetch(URL: URL).onSuccess { JSON in
            completion(cachedArray: JSON)
        }
    }

    func getDeviceToken() -> NSData{
        let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("tokenNotif")
        return (NSKeyedUnarchiver.unarchiveObjectWithFile(ArchiveURL.path!) as? NSData)!
    }

    func goToMainPageConnected(){
        let storybd = UIStoryboard(name: "Main", bundle: nil)
        let tabBar = storybd.instantiateViewControllerWithIdentifier("tabBar") as! TabBarViewController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabBar
    }
}

extension OrpheeApi {

//    var endPointClsr: ((target: eAPI) -> Endpoint<eAPI>) {
//        return { (target: eAPI) -> Endpoint<eAPI> in
//            let sampleRes: Endpoint.SampleResponseClosure = {
//                return .NetworkResponse(200, target.sampleData)
//            }
//            let endpoint = Endpoint<eAPI>(URL: self.url(target), sampleResponseClosure: sampleRes)
//
//            switch target {
//            case .downloadFromAWS(let url):
//                return Endpoint<eAPI>(URL: url, sampleResponseClosure: {.NetworkResponse(200, target.sampleData) })
//            case .uploadToAWS(let url):
//                return Endpoint<eAPI>(URL: url, sampleResponseClosure: {.NetworkResponse(200, target.sampleData) }).endpointByAddingHTTPHeaderFields(["Content-Type" : "audio/x-midi"])
//            case .createCreation(let name, let userID, let getURL,let token):
//                let params = ["name" : name, "creator" : userID, "url" : getURL]
//                let auth = ["Authorization": "Bearer \(token)"]
//                return Endpoint<eAPI>(URL: self.url(target), sampleResponseClosure: sampleRes, method: target.method, parameters: params, parameterEncoding: .JSON, httpHeaderFields: auth)
//
//            default:
//                return endpoint
//            }
//        }
//    }
//
//    var prov: RxMoyaProvider<eAPI> {
//        return RxMoyaProvider<eAPI>(endpointClosure: self.endPointClsr)
//    }
//
//    private func url(target: TargetType) -> String {
//        return target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
//    }
//
//    func sendCreationToServer(name: String, userID: String, get: String, token: String) -> Observable<Creation> {
//
////        let stores =
////            .publish()
//
////        let upload = PublishSubject<Moya.Response>()
////        stores.subscribeNext { (put, _) in
////            self.uploadToAWS(put, creationData: data)
////                .debug("upload")
////                .bindTo(upload)
////                .addDisposableTo(self.rx_disposeBag)
////        }.addDisposableTo(rx_disposeBag)
//
//
////        let getURLs = [stores.map({ $0.1 }), upload.map({ _ in "" })].combineLatest { data in
////            return data[0]
////            }.debug("combine")
////
//
////        stores.connect().addDisposableTo(rx_disposeBag)
//
//        let target = eAPI.createCreation(name: name, userID: userID, getURL: get, token: token)
//        return self.prov.request(target)
//                .debug("create")
//                .filterSuccessfulStatusCodes()
//                .mapJSON()
//                .map { data -> Creation? in
//                    return try Creation.decode(data)
//                }
//                .filterNil()
//            }
//
////    }
//
//    func getStoreURLS() ->Observable<(String, String)> {
//        return self.prov.request(.getMIDIStore)
//            .debug("store")
//            .doOnNext { input in print(input) }
//            .filterSuccessfulStatusCodes()
//            .mapJSON()
//            .map { data -> (String, String)? in
//                if let json = data as? [String : String],
//                    let get = json["urlGet"],
//                    let put = json["urlPut"] {
//                    return (put, get)
//                }
//                else {
//                    print(data)
//                    return nil
//                }
//            }
//            .filterNil()
//    }
//
//    func uploadToAWS(url: String, creationData: NSData) -> Observable<Moya.Response> {
//        let target = eAPI.uploadToAWS(url: url)
//        let uploadReq = Alamofire.upload(self.endPointClsr(target: target).urlRequest, data: creationData)
//        return Observable.create { observer in
//            uploadReq.response { (_, res, data, error) in
//                print("uploading")
//                let result = convertResponseToResult(res, data: data, error: error)
//                switch result {
//                case let .Success(response):
//                    observer.onNext(response)
//                    observer.onCompleted()
//                    break
//                case let .Failure(error):
//                    observer.onError(error)
//                }
//            }
//            return NopDisposable.instance
//        }
//    }

    func sendCreationToServer(userId: String, name: String, completion: (res: AnyObject) -> ()) {
        Alamofire.request(eCreationRouter.GetStoreURL)
            .responseJSON { res in
                let response = res.response
                //                    let request = res.request
                let json = res.result

                print("Store: ", response)
                if (response?.statusCode == 200){
                    if let dic = json.value as? Dictionary<String, AnyObject>,
                        let put = dic["urlPut"] as? String,
                        let get = dic["urlGet"] as? String {
                        self.sendCreationToAmazon(name, urlPost: put, urlGet: get, completion: { (response) in
                            if (response as! String == "ok") {
                                self.createCreation(.CreateCrea(name, userId), urlGet: get, completion: completion)
                            }
                        })
                    }
                }
        }
    }

    func createCreation(router: eCreationRouter, urlGet: String, completion: (response: AnyObject) -> () ) {
        var params: [String : AnyObject]? = nil
        switch router {
        case let .CreateCrea(name, id):
            params = [
                "name": "\(name)",
                "creator": "\(id)"
            ]
        default:
            break
        }
        let headers = [
            "Authorization": "Bearer \(eCreationRouter.OAuthToken!)"
        ]
        print(params!)
        Alamofire.request(.POST, router.URLRequest, parameters: params, encoding: .JSON, headers: headers)
            .response { req, res, data, err in
                print(req, res, String.init(data: data!, encoding: NSUTF8StringEncoding), err)
//            .responseJSON { res in
//                let response = res.response
//                let req = res.request
//                let json = res.result
//
//                print("Create: ", response)
//                print(json.error, json.value, String.init(data: req!.HTTPBody!, encoding: NSUTF8StringEncoding))
//                if (response?.statusCode == 200) {
//                    if let json = json.value,
//                        let crea = try? Creation.decode(json) {
//                        self.updateCreation(crea.id, urlGet: urlGet, completion: {
//                            (response) in
//                            completion(response: response)
//                        })
//                    }
//                    else {
//                        print("error", json, response)
//                    }
//                }
        }
    }

    func sendCreationToAmazon(creationName: String, urlPost: String, urlGet: String, completion:(response: AnyObject) ->()) {
        let fm = MIDIFileManager(name: creationName)
        Alamofire.upload(eCreationRouter.StoreCrea(url: urlPost), data: fm.reader.readAllData())
            .responseJSON { res in
                let response = res.response
                print("AWS: ", response)
                completion(response: "ok")
        }
    }

    func updateCreation(id: String, urlGet: String, completion:(response: AnyObject) -> ()) {
        Alamofire.request(eCreationRouter.UpdateCrea(id, ["url" : url]))
            .responseJSON { res in
                let response = res.response

                print("Update: ", response)
                if (response!.statusCode == 200){
                    completion(response: urlGet)
                }
        }
    }

    func getCreation(url: String, destination: String, completion:(String) -> ()) {
        let dest = Request.suggestedDownloadDestination()
        print(url)
        Alamofire.download(eCreationRouter.RetrieveCrea(url: url), destination: dest)
            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    print(totalBytesRead)
                })
            }
            .responseJSON {res in
                let response = res.response

                if (response?.statusCode == 200) {
                    if let name = response?.suggestedFilename {
                        let urlDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                        completion("\(urlDirectory.path!)/\(name)")
                    }
                }
        }
    }
}