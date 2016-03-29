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

final class mySuperUser: NSObject, NSCoding{
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

func getMySuperUser() -> mySuperUser{
    return (NSKeyedUnarchiver.unarchiveObjectWithFile(mySuperUser.ArchiveURL.path!) as? mySuperUser)!
}

func updateMyUser(id: String){
    if (OrpheeReachability().isConnected()){
        OrpheeApi().getInfoUserById(id, completion: { (infoUser) in
            let user = infoUser as! mySuperUser
            do {
                let monUser = try mySuperUser.decode(user)
                saveUser(monUser)
            } catch let error {
                print(error)
            }
        })
    }
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

func deleteUser(){
    if ((NSKeyedUnarchiver.unarchiveObjectWithFile(mySuperUser.ArchiveURL.path!) as? mySuperUser) != nil){
        NSKeyedArchiver.archiveRootObject("", toFile: mySuperUser.ArchiveURL.path!)
    }
}

extension mySuperUser: Decodable {
    static func decode(j: AnyObject) throws -> mySuperUser {
        return try mySuperUser(
            name:         j => "name",
            id:           j => "_id",
            picture:      j =>? "picture",
            token:        j =>? "token",
            username:     j =>? "username",
            likes:        j => "likes"
            )!
    }
}