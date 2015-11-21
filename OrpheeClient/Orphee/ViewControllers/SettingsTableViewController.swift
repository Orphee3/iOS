//
//  SettingsTableViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 04/09/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit

class SettingsTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func disconnect(sender: UIButton){
        NSUserDefaults.standardUserDefaults().removeObjectForKey("myUser")
    }
}