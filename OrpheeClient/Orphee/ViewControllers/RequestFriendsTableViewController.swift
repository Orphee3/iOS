//
//  RequestFriendsTableViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 31/08/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class RequestFriendsTableViewController: UITableViewController{
    var user = User!()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "RequestFriendCustomCell", bundle: nil), forCellReuseIdentifier: "requestFriend")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("myUser") as? NSData {
            self.user = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! User
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.user.arrayFriendShipRequests.isEmpty){
            return 0
        }
        else{
            return self.user.arrayFriendShipRequests.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: RequestFriendCustomCell! = tableView.dequeueReusableCellWithIdentifier("requestFriend") as? RequestFriendCustomCell
            cell.profilName.text = self.user.arrayFriendShipRequests[indexPath.row].name
            cell.id = self.user.arrayFriendShipRequests[indexPath.row].id
        return cell
    }
}