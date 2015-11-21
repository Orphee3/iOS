//
//  Room.swift
//  Orphee
//
//  Created by Jeromin Lebon on 19/11/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation

class Room{
    var lastMessage: String!
    var lastMessageDate: String!
    var peoples: [String] = []
    var peoplesId: [String] = []
    var peoplesPicture: [String] = []
    
    init(RoomElement: Dictionary<String, AnyObject>){
        if let lastMessage = RoomElement["lastMessage"] as? Dictionary<String, AnyObject>{
            print(lastMessage)
            self.lastMessage = lastMessage["message"] as? String
        }
        
        if let lastMessageDate = RoomElement["lastMessageDate"] as? String{
            print(lastMessageDate)
            self.lastMessageDate = lastMessageDate
        }
        
        print(RoomElement["people"])
        if let peoples = RoomElement["people"] as? Array<Dictionary<String, AnyObject>>{
            for obj in peoples{
                if let name = obj["name"] as? String{
                    self.peoples.append(name)
                }
                if let id = obj["_id"] as? String{
                    self.peoplesId.append(id)
                }
                if let picture = obj["picture"] as? String{
                    self.peoplesPicture.append(picture)
                }
            }
        }
    }
}