//
//  myUser.swift
//  Orphee
//
//  Created by Jeromin Lebon on 12/03/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import Decodable
import Haneke

struct myUser{
    let name: String
    let id: String
    let picture: String?
    var token: String?
    var username: String?
    var likes: Array<String>
}

extension myUser: Decodable {
    static func decode(j: AnyObject) throws -> myUser {
        return try myUser(
            name:         j => "name",
            id:           j => "_id",
            picture:      j =>? "picture",
            token:        j =>? "token",
            username:     j =>? "username",
            likes:        j => "likes"
        )
    }
}

func getMyUser(completion : (response: myUser) -> ()){
    if let retrievedDict = NSUserDefaults().dictionaryForKey("myUser") {
        do {
            print("lol")
            var token: String!
            var monUser = try myUser.decode(retrievedDict)
            if let retrievedToken = NSUserDefaults().objectForKey("myToken"){
                token = retrievedToken as! String
            }
            monUser.token = token
            completion(response: monUser)
        } catch let error {
            print(error)
        }
    }
}

func updateMyUser(like: String, completion : (response: myUser) -> ()){
    if var retrievedDict = NSUserDefaults().objectForKey("myUser") as? Dictionary<String, AnyObject> {
        do {
            var token: String!
            var likes = retrievedDict["likes"] as! Array<String>
            let i = checkIfLikeExists(like, likes: likes)
            if (i == 0){
                likes.append(like)
            }
            else{
                likes.removeAtIndex(i)
            }
            retrievedDict["likes"] = likes
            NSUserDefaults().setObject(retrievedDict, forKey: "myUser")
            var monUser = try myUser.decode(retrievedDict)
            if let retrievedToken = NSUserDefaults().objectForKey("myToken"){
                token = retrievedToken as! String
            }
            monUser.token = token
            completion(response: monUser)
        } catch let error {
            print(error)
        }
    }
}

func checkIfLikeExists(like: String, likes: Array<String>) -> Int{
    var i = 0
    for elem in likes{
        if (elem == like){
            return i
        }
        i += 1
    }
    return 0
}