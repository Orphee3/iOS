//
//  AddFriendsForChatTableViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 25/11/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import DZNEmptyDataSet

class AddFriendsForChatTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    var user = User!()
    var arrayFriends: [User] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        print("mdr")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        tableView.registerNib(UINib(nibName: "FriendCustomCell", bundle: nil), forCellReuseIdentifier: "FriendCustomCell")
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("myUser") as? NSData {
            user = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! User
        }
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        if (OrpheeReachability().isConnected()){
            getFriends()
        }
    }
    
    func getFriends(){
        OrpheeApi().getFriends(user.id, completion: {(response) -> () in
            self.arrayFriends = response as! [User]
            self.tableView.reloadData()
        })
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (arrayFriends.isEmpty){
            return 0
        }else{
            return arrayFriends.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCustomCell") as! FriendCustomCell
        cell.putInGraphic(self.arrayFriends[indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("toConversation", sender: self.arrayFriends[indexPath.row])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toConversation"){
            let view = segue.destinationViewController as! ConversationViewController
            print(sender)
            view.correspondant = sender as! User
        }
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        let image = UIImage(named: "orpheeLogoRoundSmall")
        return image
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Vous n'avez pas encore d'amitiés sur Orphée"
        let attributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 19)!]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Vous pouvez demander une amitié en vous rendant dans l'onglet Social"
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraph.alignment = NSTextAlignment.Center
        
        let attributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 14)!, NSForegroundColorAttributeName: UIColor.lightGrayColor(), NSParagraphStyleAttributeName: paragraph]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
}