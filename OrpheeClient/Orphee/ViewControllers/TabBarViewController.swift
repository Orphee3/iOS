//
//  TabBarViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 21/08/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TabBarViewController.friendNotification(_:)), name: "requestFriend", object: nil)
        UITabBar.appearance().barTintColor = UIColor(red: (241/255.0), green: (245/255.0), blue: (248/255.0), alpha: 1.0)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blackColor()], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)], forState:.Selected)
    }
    
    func friendNotification(notif: NSNotification){
        let navController = self.childViewControllers[2] as! UINavigationController
        navController.tabBarItem.badgeValue = "1";
    }
}