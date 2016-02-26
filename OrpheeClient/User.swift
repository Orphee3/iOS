//
//  User.swift
//  Orphee
//
//  Created by Jeromin Lebon on 23/02/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import Decodable
import RealmSwift


final class User: Object{
    dynamic var name: String
    dynamic var id: String
    dynamic var picture: String?
    dynamic var token: String?
    
    init(name: String, id: String, picture: String?, token: String?){
        self.name = name
        self.id = id
        self.picture = picture
        self.token = token
        super.init()
    }
    
    required init() {
        self.name = ""
        self.id = ""
        self.picture = ""
        self.token = ""
        super.init()
    }
}

extension User: Decodable {
    static func decode(j: AnyObject) throws -> User {
        return try User(
            name:         j => "name",
            id:           j => "_id",
            picture:      j =>? "picture",
            token:        j =>? "token"
        )
    }
}
