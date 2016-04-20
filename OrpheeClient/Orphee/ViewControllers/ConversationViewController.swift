//
//  ConversationViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 17/04/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import SlackTextViewController

class ConversationViewController: SLKTextViewController {
    var myUser: mySuperUser!
    var friend: User!
    
    var messages: [Message] = []
    
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
        
        self.typingIndicatorView?.canResignByTouch = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        print("MERDE")
        OrpheeApi().getConversation(friend.id!, token: myUser.token!, completion: { (response) in
            print(response)
            for elem in response{
                do {
                    print("okay")
                    let message = try Message.decode(elem)
                    self.messages.append(message)
                } catch let error {
                    print(error)
                }
            }
            print(self.messages)
            self.tableView?.reloadData()
        })
        print("PUTAIN")
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 44.0
        self.tableView?.registerNib(UINib(nibName: "ConversationCell", bundle: nil), forCellReuseIdentifier: "ConversationCell")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ConversationViewController.messageReceived(_:)), name: "message", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    func messageReceived(notif: NSNotification){
        print(notif)
        
        do {
            let msg = notif.object?.objectAtIndex(0)["message"]
            let messageToDecode = try Message.decode(msg!!)
            self.messages.append(messageToDecode)
            self.tableView?.reloadData()
        } catch let error {
            print(error)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("ConversationCell") as? ConversationCell{
            cell.fillCell(messages[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func didPressRightButton(sender: AnyObject!) {
        self.textView.refreshFirstResponder()
        
        do {
            let message = ["_id": myUser.id, "creator": ["_id": myUser.id, "name": myUser.name, "picture": myUser.picture!], "dateCreation": "", "message": self.textView.text.copy() as! String]
            let messageToDecode = try Message.decode(message)
            self.messages.append(messageToDecode)
            SocketManager.sharedInstance.sendMessage(friend.id!, message: messageToDecode.message)
            self.tableView?.reloadData()
        } catch let error {
            print(error)
        }
        
        
        //self.messages.insert(["id":"\(user.id)", "message":"\(message)"], atIndex: 0)
        //self.tableView.reloadData()
        // SocketManager().sendMessage(friend.id, message: message)
        super.didPressRightButton(sender)
    }
}