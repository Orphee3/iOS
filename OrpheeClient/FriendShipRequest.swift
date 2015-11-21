//
//  FriendShipRequest.swift
//  Orphee
//
//  Created by Jeromin Lebon on 22/10/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation

class FriendShipRequest: NSObject, NSCoding{
    var name: String!
    var picture: String!
    var id: String!
    
    init(FriendShipRequest: Dictionary<String, AnyObject>){
        if let name = FriendShipRequest["name"] as! String?{
            self.name = name
        }
        if let picture = FriendShipRequest["picture"] as! String?{
            self.picture = picture
        }
        if let id = FriendShipRequest["_id"] as! String?{
            self.id = id
        }
    }
    
    required init(coder decoder: NSCoder) {
        super.init()
        self.name = decoder.decodeObjectForKey("name") as? String
        self.picture = decoder.decodeObjectForKey("picture") as? String
        self.id = decoder.decodeObjectForKey("id") as? String
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.name, forKey:"name")
        coder.encodeObject(self.picture, forKey:"picture")
        coder.encodeObject(self.id, forKey:"id")
    }

}