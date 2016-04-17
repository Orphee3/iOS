//
//  Message.swift
//  Orphee
//
//  Created by Jeromin Lebon on 17/04/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import Decodable

struct Message{
    let id: String?
    let creator: User
    let dateCreation: String
    let message: String
}

extension Message: Decodable {
    static func decode(j: AnyObject) throws -> Message {
        return try Message(
            id:           j =>? "_id",
            creator:         j => "creator",
            dateCreation:          j => "dateCreation",
            message:         j => "message"
        )
    }
}