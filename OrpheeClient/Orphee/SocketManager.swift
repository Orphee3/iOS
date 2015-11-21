//
//  SocketManager.swift
//  Orphee
//
//  Created by Jeromin Lebon on 21/08/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import Socket_IO_Client_Swift

class SocketManager {
    static let sharedInstance = SocketManager()
    var socket = SocketIOClient!()
    var user: User!
    
    func connectSocket(){
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("myUser") as? NSData {
            user = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! User
            self.socket = SocketIOClient(socketURL: "http://163.5.84.242:3000", opts: ["connectParams" : ["token": user.token]])
        }
        socket.on("connect") {data, ack in
            print("socket connected")
            self.socket.emit("subscribe", ["channel":self.user.id])
        }
        
        socket.connect()
        
        socket.on("error") {data, ack in
            print("error")
        }
        
        socket.on("newFriend") {data, ack in
            print("newFriend data : \(data)")
        }
        
        socket.on("private message"){data, ack in
            print(data)
            var message: String
            message = data?.objectAtIndex(0)["message"]!!["message"] as! String
            NSNotificationCenter.defaultCenter().postNotificationName("message", object: message)
        }
        
        socket.on("friend") {data, ack in
            print("friend data : \(data! as Array)")
            self.user.arrayFriendShipRequests.insert(FriendShipRequest(FriendShipRequest: data?.objectAtIndex(0)["userSource"] as! Dictionary<String, AnyObject>), atIndex: 0)
            let userData = NSKeyedArchiver.archivedDataWithRootObject(self.user)
            NSUserDefaults.standardUserDefaults().setObject(userData, forKey: "myUser")
            self.notifyApp("requestFriend", data: data! as Array<AnyObject>)
        }
        
        socket.on("comments") {data, ack in
            print("comment data : \(data)")
        }
    }
    
    func sendMessage(toPerson: String, message: String){
        self.socket.emit("private message", ["to": toPerson, "message": message])
    }
    
    func notifyApp(key: String, data: Array<AnyObject>) {
        NSNotificationCenter.defaultCenter().postNotificationName(key, object: self, userInfo: ["json":data])
    }
    
    func disconnectFromSocket(){
        socket.disconnect(fast: true)
    }
}