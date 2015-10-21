//
//  Creation.swift
//  Orphee
//
//  Created by Jeromin Lebon on 17/10/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation

class Creation{
    var name: String!
    var picture: String!
    var id: String!
    var nbCommments: Int!
    var nbLikes: Int!
    var url: String!
    
    init(Creation: Dictionary<String, AnyObject>){
        if let name = Creation["name"] as? String{
            self.name = name
        }
        if let picture = Creation["picture"] as? String{
            self.picture = picture
        }
        if let id = Creation["_id"] as? String{
            self.id = id
        }
        if let nbComments = Creation["nbComments"] as? Int{
            self.nbCommments = nbComments
        }
        if let nbLikes = Creation["nbLikes"] as? Int{
            self.nbLikes = nbLikes
        }
        if let url = Creation["url"] as? String{
            self.url = url
        }
    }
}