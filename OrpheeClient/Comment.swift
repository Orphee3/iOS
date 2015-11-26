//
//  Comment.swift
//  Orphee
//
//  Created by Jeromin Lebon on 19/10/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation

class Comment{
    var message: String!
    var user: String!
    var picture: String!
    
    init(Comment: String, user: String, picture: String){
        if let message = Comment as String?{
            self.message = message
        }
        if let user = user as String?{
            self.user = user
        }
        if let picture = picture as String?{
            self.picture = picture
        }
    }
}