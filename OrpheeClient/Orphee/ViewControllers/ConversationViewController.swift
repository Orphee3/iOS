//
//  ConversationViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 20/08/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import SlackTextViewController

class ConversationViewController: SLKTextViewController {
    var user = User!()
    var correspondant = User!()
    
    var messages: Array<Dictionary<String, String>> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bounces = true
        self.shakeToClearEnabled = true
        self.keyboardPanningEnabled = true
        self.inverted = false
        
        self.textView.placeholder = "Message"
        self.textView.placeholderColor = UIColor.lightGrayColor()
        
        self.rightButton.setTitle("Send", forState: UIControlState.Normal)
        
        self.textInputbar.autoHideRightButton = true
        self.textInputbar.maxCharCount = 140
        self.textInputbar.counterStyle = SLKCounterStyle.Split
        
        self.typingIndicatorView.canResignByTouch = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.registerNib(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "messageCell")
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("myUser") as? NSData {
            user = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! User
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "messageReceived:", name: "message", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    func messageReceived(notif: NSNotification){    
        let id = notif.object?.objectAtIndex(0)["source"]!!["_id"] as! String
        let msg = notif.object?.objectAtIndex(0)["message"]!!["message"] as! String
        let message = ["id":"\(id)", "message":"\(msg)"]
        self.messages.insert(message, atIndex: 0)
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("messageCell") as! MessageCell
        if (self.messages[indexPath.row]["id"] == user.id){
            cell.message.text = self.messages[indexPath.row]["message"]
            cell.nameUser.text = self.user.name
            if let picture = user.picture{
                cell.imgUser.sd_setImageWithURL(NSURL(string: picture), placeholderImage: UIImage(named: "emptygrayprofile"))
            }else{
                cell.imgUser.image = UIImage(named: "emptygrayprofile")
            }
        }
        else if (self.messages[indexPath.row]["id"] == correspondant.id){
            cell.message.text = self.messages[indexPath.row]["message"]
            cell.nameUser.text = self.correspondant.name
            if let picture = correspondant.picture{
                cell.imgUser.sd_setImageWithURL(NSURL(string: picture), placeholderImage: UIImage(named: "emptygrayprofile"))
            }else{
                cell.imgUser.image = UIImage(named: "emptygrayprofile")
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func didPressRightButton(sender: AnyObject!) {
        self.textView.refreshFirstResponder()
        
        let message = self.textView.text.copy() as! String
        self.messages.insert(["id":"\(user.id)", "message":"\(message)"], atIndex: 0)
        self.tableView.reloadData()
        SocketManager.sharedInstance.sendMessage(correspondant.id, message: message)
        super.didPressRightButton(sender)
    }
}