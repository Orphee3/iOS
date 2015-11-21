//
//  User.swift
//  Orphee
//
//  Created by Jeromin Lebon on 17/10/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation

class User : NSObject{
    var name: String!
    var picture: String!
    var id: String!
    var nbCreations: Int!
    
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
        }
        if let token = User["token"] as? String{
            self.token = token
        }
    }
}