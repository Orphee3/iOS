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
    var popUp: AskLoginViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (13/255.0), green: (71/255.0), blue: (161/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        if (popUp != nil){
            popUp.view.removeFromSuperview()
        }
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
        popUp = AskLoginViewController(nibName: "AskLoginViewController", bundle: nil)
        popUp.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        popUp.title = "This is a popup view"
        popUp.showInView(self.view, animated: true)
    }
}