//
//  MessengerViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 20/08/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit

class MessengerViewController: UITableViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        if var _ = NSUserDefaults.standardUserDefaults().objectForKey("token"){
            print("y a un token")
            SocketManager.sharedInstance.connectSocket()
        }
        else{
            print("no token")
            prepareViewForLogin()
        }
    }
    
    func prepareViewForLogin(){

    }
}