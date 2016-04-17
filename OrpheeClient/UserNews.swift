//
//  friendRequest.swift
//  Orphee
//
//  Created by Jeromin Lebon on 16/04/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import Decodable

struct UserNews{
    let id: String
    let media: Media?
    let type: String
    let userSource: User?
}

extension UserNews: Decodable {
    static func decode(j: AnyObject) throws -> UserNews {
        return try UserNews(
            id:           j => "_id",
            media:        j =>? "media",
            type:         j => "type",
            userSource:   j =>? "userSource"
        )
    }
}
