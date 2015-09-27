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
    var arrayRequest: [JSON] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "RequestFriendCustomCell", bundle: nil), forCellReuseIdentifier: "requestFriend")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        getFriendsRequests()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    func getFriendsRequests(){
        if let request = NSUserDefaults.standardUserDefaults().objectForKey("friendsRequests") as? Array<AnyObject>{
            for r in request{
                print(r)
                arrayRequest.append(JSON(r))
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (arrayRequest.isEmpty){
            return 0
        }
        else{
            return arrayRequest.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: RequestFriendCustomCell! = tableView.dequeueReusableCellWithIdentifier("requestFriend") as? RequestFriendCustomCell
            print(arrayRequest[indexPath.row]["userSource"])
            cell.profilName.text = arrayRequest[indexPath.row]["userSource"]["name"].string!
            cell.id = arrayRequest[indexPath.row]["userSource"]["_id"].string!
        return cell
    }
}