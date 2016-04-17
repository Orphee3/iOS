
//
//  Media.swift
//  Orphee
//
//  Created by Jeromin Lebon on 16/04/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import Decodable

struct Media{
    let id: String
    let name: String?
    var url: String?
}

extension Media: Decodable {
    static func decode(j: AnyObject) throws -> Media {
        return try Media(
            id:           j => "_id",
            name:         j => "name",
            url:          j => "url"
        )
    }
}
