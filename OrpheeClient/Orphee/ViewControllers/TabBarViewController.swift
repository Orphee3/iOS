//
//  TabBarViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 21/08/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class TabBarViewController: UITabBarController, UITabBarControllerDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "friendNotification:", name: "requestFriend", object: nil)
        UITabBar.appearance().barTintColor = UIColor(red: (241/255.0), green: (245/255.0), blue: (248/255.0), alpha: 1.0)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blackColor()], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)], forState:.Selected)
    }
    
    func friendNotification(notif: NSNotification){
        let navController = self.childViewControllers[4] as! UINavigationController
        navController.tabBarItem.badgeValue = "1";
        var requests = notif.userInfo?.indexForKey("json")
        print(requests)
//        if (NSUserDefaults.standardUserDefaults().objectForKey("friendsRequest") != nil) {
//            var data: NSData = NSUserDefaults.standardUserDefaults().objectForKey("friendsRequest") as! NSData
//            var tmp: NSMutableArray = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSMutableArray
//            tmp.addObject(self.beacons[nbBeacon!])
//            data = NSKeyedArchiver.archivedDataWithRootObject(tmp)
//            NSUserDefaults.standardUserDefaults().setObject(data, forKey: "history")
//            NSUserDefaults.standardUserDefaults().synchronize()
//        }else {
//            var tmp = NSMutableArray()
//            tmp.addObject(self.beacons[nbBeacon!])
//            var data = NSKeyedArchiver.archivedDataWithRootObject(tmp)
//            NSUserDefaults.standardUserDefaults().setObject(data, forKey: "history")
//            NSUserDefaults.standardUserDefaults().synchronize()
//        }

        //print(notif.userInfo)
    }
}