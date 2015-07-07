//
//  InstrumentsTableViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 27/06/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit

class InstrumentsTableViewController: UITableViewController {
    var instrumentsList: [String] = ["violin", "guitar", "tambour", "battery", "trumpet"];
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instrumentsList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        cell.textLabel?.text = instrumentsList[indexPath.row]
        return cell;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}