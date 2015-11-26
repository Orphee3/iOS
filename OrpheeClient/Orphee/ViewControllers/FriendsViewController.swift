//
//  FriendsViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 21/08/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import DZNEmptyDataSet
import UIKit
import Alamofire

class FriendsViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource{
    var user = User!()
    var arrayFriends: [User] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("myUser") as? NSData {
            self.user = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! User
        }
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        self.tableView.tableFooterView = UIView()
        tableView.registerNib(UINib(nibName: "FriendCustomCell", bundle: nil), forCellReuseIdentifier: "FriendCustomCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        getFriends()
        self.tableView.addPullToRefresh({ [weak self] in
            if (OrpheeReachability().isConnected()){
                self!.arrayFriends = []
                self!.getFriends()
                self?.tableView.stopPullToRefresh()
            }else{
                self?.tableView.stopPullToRefresh()
            }
            })
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (arrayFriends.isEmpty){
            return 0
        }else{
            return arrayFriends.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: FriendCustomCell! = tableView.dequeueReusableCellWithIdentifier("FriendCustomCell") as? FriendCustomCell
        cell.putInGraphic(self.arrayFriends[indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "profile", bundle: nil)
        let profileView = storyboard.instantiateViewControllerWithIdentifier("profileView") as! ProfileUserTableViewController
        profileView.user = self.arrayFriends[indexPath.row]
        self.navigationController?.pushViewController(profileView, animated: true)
    }
    
    func getFriends(){
        OrpheeApi().getFriends(user.id, completion: {(response) -> () in
            self.arrayFriends = response as! [User]
            self.tableView.reloadData()
        })
    }
}