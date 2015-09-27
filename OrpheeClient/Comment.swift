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
    var user: User!
    
    init(Comment: String, user: User){
        if let message = Comment as String?{
            self.message = message
        }
        if let user = user as User?{
            self.user = user
        }
    }
}