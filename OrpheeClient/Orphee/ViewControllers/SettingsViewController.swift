//
//  SettingsViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 18/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (13/255.0), green: (71/255.0), blue: (161/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    @IBAction func deconnectionButtonPressed(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("token")
        performSegueWithIdentifier("disconnect", sender: nil)
    }
}