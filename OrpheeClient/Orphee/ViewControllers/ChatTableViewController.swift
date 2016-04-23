//
//  ChatTableViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 17/04/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView

class ChatTableViewController: UITableViewController {
    var myUser: mySuperUser!
    var arrayFriends: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if (userExists()){
            myUser = getMySuperUser()
            OrpheeApi().getFriends(myUser.id, completion: { (response) in
                for elem in response{
                    do {
                        let user = try User.decode(elem)
                        self.arrayFriends.append(user)
                    } catch let error {
                        print(error)
                    }
                }
                self.tableView.reloadData()
            })
        }else{
            callPopUp()
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!arrayFriends.isEmpty){
            return arrayFriends.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("FriendsTableViewCell") as? FriendsTableViewCell{
            cell.fillCell(arrayFriends[indexPath.row])
            cell.removeButton.tag = indexPath.row
            cell.removeButton.addTarget(self, action: #selector(FriendsTableViewController.removeFriend(_:)), forControlEvents: .TouchUpInside)
            return cell
        }
        return UITableViewCell()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("toConversation", sender: indexPath.row)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toConversation"){
            if let controller = segue.destinationViewController as? ConversationViewController{
                controller.friend = arrayFriends[sender as! Int]
                controller.myUser = myUser
            }
        }
    }
    
    func callPopUp(){
        let alertView = SCLAlertView()
        alertView.addButton("S'inscrire / Se connecter", target:self, selector:#selector(ChatTableViewController.goToRegister))
        alertView.addButton("Fermer", target: self, selector: #selector(ChatTableViewController.closePopUp))
        alertView.showCloseButton = false
        alertView.showSuccess("Orphée", subTitle: "Tu n'es pas encore inscrit ? Rejoins-nous !")
    }
    
    func goToRegister(){
        performSegueWithIdentifier("toLogin", sender: nil)
    }
    
    func closePopUp(){
        performSegueWithIdentifier("toHome", sender: nil)
    }
}
