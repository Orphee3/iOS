//
//  User.swift
//  Orphee
//
//  Created by Jeromin Lebon on 17/10/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation

class User : NSObject, NSCoding{
    var name: String!
    var picture: String!
    var id: String!
    var nbCreations: Int!
    var arrayFriendShipRequests: [FriendShipRequest] = []
    var token: String!
    
    init(User: Dictionary<String, AnyObject>){
        if let name = User["name"] as? String{
            self.name = name
        }
        if let picture = User["picture"] as? String{
            self.picture = picture
        }
        if let id = User["_id"] as? String{
            self.id = id
        }
        if let nbCreations = User["creations"] as? Array<String>{
            self.nbCreations = nbCreations.count
            print(nbCreations.count)
        }
        if let token = User["token"] as? String{
            self.token = token
        }
        //self.arrayFriendShipRequests = []
    }
    
    required init(coder decoder: NSCoder) {
        super.init()
        self.name = decoder.decodeObjectForKey("name") as? String
        self.picture = decoder.decodeObjectForKey("picture") as? String
        self.id = decoder.decodeObjectForKey("id") as? String
        self.nbCreations = decoder.decodeObjectForKey("nbCreations") as? Int
        self.token = decoder.decodeObjectForKey("token") as? String
        if let array = decoder.decodeObjectForKey("friendShipRequests") as! [FriendShipRequest]?{
            self.arrayFriendShipRequests = array
        }
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.name, forKey:"name")
        coder.encodeObject(self.picture, forKey:"picture")
        coder.encodeObject(self.id, forKey:"id")
        coder.encodeInt(Int32(self.nbCreations), forKey:"nbCreations")
        coder.encodeObject(self.token, forKey:"token")
        coder.encodeObject(self.arrayFriendShipRequests, forKey: "friendShipRequests")
    }
}