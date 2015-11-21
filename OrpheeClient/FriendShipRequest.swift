//
//  FriendShipRequest.swift
//  Orphee
//
//  Created by Jeromin Lebon on 22/10/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation

class FriendShipRequest{
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
}