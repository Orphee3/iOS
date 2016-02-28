//
//  UserTableViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 28/02/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import Haneke

class UserTableViewController: UITableViewController {
    var user: User!
    var arrayCreations: [Creation] = []
    override func viewDidLoad() {
        super.viewDidLoad()
       // OrpheeApi().getInfoUserById(<#T##id: String##String#>, completion: <#T##(infoUser: [AnyObject]) -> ()#>)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!arrayCreations.isEmpty){
            return arrayCreations.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("UserTableViewCell") as? UserTableViewCell{
            cell.fillCell(arrayCreations[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
}