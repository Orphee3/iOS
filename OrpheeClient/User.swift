//
//  User.swift
//  Orphee
//
//  Created by Jeromin Lebon on 23/02/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import Decodable

struct User{
    let name: String
    let id: String
    let picture: String?
    var token: String?
    var username: String?
}

extension User: Decodable {
    static func decode(j: AnyObject) throws -> User {
        return try User(
            name:         j => "name",
            id:           j => "_id",
            picture:      j =>? "picture",
            token:        j =>? "token",
            username:     j =>? "username"
        )
    }
}
