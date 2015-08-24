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
    static let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
    let myId = NSUserDefaults.standardUserDefaults().objectForKey("myId") as! String
    let socket = SocketIOClient(socketURL: "http://163.5.84.242:3000", opts: ["connectParams" : ["token": token]])
    
    func connectSocket(){
        socket.on("connect") {data, ack in
            print("socket connected")
            self.socket.emit("subscribe", ["channel":self.myId])
        }
        
        socket.connect()
        
        socket.on("error") {data, ack in
            print("error")
        }
        
        socket.on("private message") {data, ack in
            print("private message")
            print(data)
        }
        
        socket.on("newFriend") {data, ack in
            print("newFriend data : \(data)")
        }
        
        socket.on("friend") {data, ack in
            print("friend data : \(data)")
        }
    }
    
    func sendMessage(toPerson: String, message: String){
        socket.emit("private message", ["to": toPerson, "message": message]);
    }
}