//
//  OrpheeReachability.swift
//  Orphee
//
//  Created by Jeromin Lebon on 21/11/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation

class OrpheeReachability{
    func isConnected() -> Bool{
        let status = Reach().connectionStatus()
        switch status {
        case .Unknown, .Offline:
            print("Not connected")
            return false
        case .Online(.WWAN):
            print("Connected via WWAN")
            return true
        case .Online(.WiFi):
            print("Connected via WiFi")
            return true
        }
    }
}