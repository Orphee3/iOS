//
//  Comment.swift
//  Orphee
//
//  Created by Jeromin Lebon on 05/03/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import Decodable

struct Comment{
    let id: String
    let creator: User
    let dateCreation: String
    let message: String
}

extension Comment: Decodable {
    static func decode(j: AnyObject) throws -> Comment {
        return try Comment(
            id:             j => "_id",
            creator:        j => "creator",
            dateCreation:   j => "dateCreation",
            message:        j => "message"
        )
    }
}