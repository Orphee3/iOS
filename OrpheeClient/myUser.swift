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

class mySuperUser: NSObject, NSCoding{
    var name: String = ""
    var id: String = ""
    var picture: String? = nil
    var token: String? = nil
    var username: String? = nil
    var likes: Array<String> = []
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("user")
    
    init?(name: String, id: String, picture: String?, token: String?, username: String?, likes: Array<String>){
        self.name = name
        self.id = id
        self.picture = picture
        self.token = token
        self.username = username
        self.likes = likes
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder){
        let name = aDecoder.decodeObjectForKey("name") as! String
        let id = aDecoder.decodeObjectForKey("id") as! String
        let picture = aDecoder.decodeObjectForKey("picture") as! String?
        let token = aDecoder.decodeObjectForKey("token") as! String?
        let username = aDecoder.decodeObjectForKey("username") as! String?
        let likes = aDecoder.decodeObjectForKey("likes") as! Array<String>
        self.init(name: name, id: id, picture: picture, token: token, username: username, likes: likes)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(picture, forKey: "picture")
        aCoder.encodeObject(token, forKey: "token")
        aCoder.encodeObject(username, forKey: "username")
        aCoder.encodeObject(likes, forKey: "likes")
    }
}

struct myUser{
    let name: String
    let id: String
    let picture: String?
    var token: String?
    var username: String?
    var likes: Array<String>
}

func getMySuperUser() -> mySuperUser{
    return (NSKeyedUnarchiver.unarchiveObjectWithFile(mySuperUser.ArchiveURL.path!) as? mySuperUser)!
}

func userExists() -> Bool{
    if ((NSKeyedUnarchiver.unarchiveObjectWithFile(mySuperUser.ArchiveURL.path!) as? mySuperUser) != nil){
        return true
    }
    return false
}

func saveUser(user: mySuperUser){
    let isSaved = NSKeyedArchiver.archiveRootObject(user, toFile: mySuperUser.ArchiveURL.path!)
    if (isSaved){
        print("save OK")
    }
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
            var token: String!
            var monUser = try myUser.decode(retrievedDict)
            if let retrievedToken = NSUserDefaults().objectForKey("myToken"){
                token = retrievedToken as! String
            }
            monUser.token = token
            print("ouioui")
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