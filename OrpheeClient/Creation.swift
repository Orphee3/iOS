//
//  Creation.swift
//  Orphee
//
//  Created by Jeromin Lebon on 23/02/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import Decodable

struct Creation{
    let name: String
    let id: String
    let nbLikes: Int
    let nbComments: Int
    let url: String
    let isPrivate: Bool
    let creator: [User]
}

extension Creation: Decodable {
    static func decode(j: AnyObject) throws -> Creation {
        return try Creation(
            name:           j => "name",
            id:             j => "_id",
            nbLikes:        j => "nbLikes",
            nbComments:     j => "nbComments",
            url:            j => "url",
            isPrivate:      j => "isPrivate",
            creator:        j => "creator"
        )
    }
}