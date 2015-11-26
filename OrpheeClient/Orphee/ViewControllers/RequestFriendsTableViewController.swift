//
//  RequestFriendsTableViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 31/08/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import DZNEmptyDataSet
import Alamofire

class RequestFriendsTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource{
    var user = User!()
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("myUser") as? NSData {
            self.user = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! User
        }
        
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.registerNib(UINib(nibName: "RequestFriendCustomCell", bundle: nil), forCellReuseIdentifier: "requestFriend")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        let image = UIImage(named: "orpheeLogoRoundSmall")
        return image
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Vous n'avez aucune demande en attente"
        let attributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 19)!]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Vous pouvez demander une amitié en vous rendant dans l'onglet Social"
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraph.alignment = NSTextAlignment.Center
        
        let attributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 14)!, NSForegroundColorAttributeName: UIColor.lightGrayColor(), NSParagraphStyleAttributeName: paragraph]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
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
        }else{
            return self.user.arrayFriendShipRequests.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: RequestFriendCustomCell! = tableView.dequeueReusableCellWithIdentifier("requestFriend") as? RequestFriendCustomCell
        print("ok")
        cell.putInGraphic(self.user.arrayFriendShipRequests[indexPath.row])
        
        cell.buttonAccept.addTarget(self, action: "acceptFriend:", forControlEvents: .TouchUpInside)
        cell.buttonAccept.tag = indexPath.row
        cell.buttonDecline.addTarget(self, action: "declineFriend:", forControlEvents: .TouchUpInside)
        cell.buttonDecline.tag = indexPath.row
        return cell
    }
    
    func acceptFriend(sender: UIButton){
        print("acceptFriend")
        let headers = [
            "Authorization": "Bearer \(user.token)"
        ]
        Alamofire.request(.GET, "http://163.5.84.242:3000/api/acceptfriend/\(self.user.arrayFriendShipRequests[sender.tag].id)", headers: headers).responseJSON{request, response, json in
            if (response?.statusCode == 200){
                self.user.arrayFriendShipRequests.removeAtIndex(sender.tag)
                let userData = NSKeyedArchiver.archivedDataWithRootObject(self.user)
                NSUserDefaults.standardUserDefaults().setObject(userData, forKey: "myUser")
                self.tableView.reloadData()
            }
            else{
                
            }
            
        }
    }
    
    func declineFriend(sender: UIButton){
        self.user.arrayFriendShipRequests.removeAtIndex(sender.tag)
        let userData = NSKeyedArchiver.archivedDataWithRootObject(self.user)
        NSUserDefaults.standardUserDefaults().setObject(userData, forKey: "myUser")
        self.tableView.reloadData()
    }
    
}