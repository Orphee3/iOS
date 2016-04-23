//
//  FriendsTableViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 16/04/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit

class FriendsTableViewController: UITableViewController{
    var myUser: mySuperUser!
    var arrayFriends: [User] = []
    var arrayNews: [UserNews] = []

    override func viewDidLoad() {
        super.viewDidLoad()
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
            OrpheeApi().getNews(myUser.id, token: myUser.token!, completion: { (response) in
                for elem in response{
                    do {
                        let askFriend = try UserNews.decode(elem)
                        if (askFriend.type == "friend"){
                            self.arrayNews.append(askFriend)
                        }
                    } catch let error {
                        print(error)
                    }
                }
                self.tableView.reloadData()
            })
        }
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 1){
            if (!arrayFriends.isEmpty){
                print("friends : \(arrayFriends.count)")
                return arrayFriends.count
            }
        }
        if (section == 0){
            if (!arrayNews.isEmpty){
                print("news : \(arrayNews.count)")
                return arrayNews.count
            }
        }
        return 0
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch section
        {
        case 0:
            return "Demandes en attente"
        case 1:
            return "Amis"
        default:
            return "Amis"
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 1){
            if let cell = tableView.dequeueReusableCellWithIdentifier("FriendsTableViewCell") as? FriendsTableViewCell{
                cell.fillCell(arrayFriends[indexPath.row])
                cell.removeButton.tag = indexPath.row
                cell.removeButton.addTarget(self, action: #selector(FriendsTableViewController.removeFriend(_:)), forControlEvents: .TouchUpInside)
                return cell
            }
        }
        if (indexPath.section == 0){
            if let cell = tableView.dequeueReusableCellWithIdentifier("AskFriendTableViewCell") as? AskFriendTableViewCell{
                cell.fillCell(arrayNews[indexPath.row])
                cell.acceptButton.tag = indexPath.row
                cell.acceptButton.addTarget(self, action: #selector(FriendsTableViewController.acceptFriend(_:)), forControlEvents: .TouchUpInside)
                cell.refuseButton.tag = indexPath.row

                return cell
            }
        }
        return UITableViewCell()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("toDetailsUser", sender: indexPath)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toDetailsUser"){
            if let controller = segue.destinationViewController as? UserTableViewController{
                if (sender!.section == 1){
                    controller.id = arrayFriends[sender!.row as Int].id
                    controller.user = arrayFriends[sender!.row as Int]
                }
                if (sender!.section == 0){
                    controller.id = arrayNews[sender!.row as Int].userSource!.id
                    controller.user = arrayNews[sender!.row as Int].userSource!
                }
            }
        }
    }

    func acceptFriend(sender: UIButton){
        OrpheeApi().acceptFriend(arrayNews[sender.tag].userSource!.id!, token: myUser.token!) { (response) in
            if (response == "ok"){
                self.arrayFriends.append(self.arrayNews[sender.tag].userSource!)
                self.arrayNews.removeAtIndex(sender.tag)
                self.tableView.reloadData()
            }else{
                print("error")
            }
        }
    }

    func removeFriend(sender: UIButton){
        OrpheeApi().removeFriend(arrayFriends[sender.tag].id!, token: myUser.token!) { (response) in
            if (response as! String == "ok"){
                self.arrayFriends.removeAtIndex(sender.tag)
                self.tableView.reloadData()
            }else{
                print("error")
            }
        }
    }

    func refuseFriend(){

    }
}
