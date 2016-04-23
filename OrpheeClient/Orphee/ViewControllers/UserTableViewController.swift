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
import SCLAlertView

class UserTableViewController: UITableViewController {
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var nameUser: UILabel!
    @IBOutlet var askButton: UIButton!

    var id: String!
    var user: User!
    var arrayCreations: [Creation] = []
    var MyUser: mySuperUser!
    var arrayFriends: [User] = []
    var isFriend = false

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUser()
        OrpheeApi().getInfoUserById(id) { (infoUser) in
            for elem in infoUser{
                do {
                    let creation = try Creation.decode(elem)
                    self.arrayCreations.append(creation)
                } catch let error {
                    print(error)
                }
            }
            self.tableView.reloadData()
        }
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
    }

    func prepareUser(){
        nameUser.text = self.user.name
        if let picture = user.picture{
            imgUser.kf_setImageWithURL(NSURL(string: picture)!, placeholderImage: UIImage(named: "emptyprofile"))
        }else{
            imgUser.image = UIImage(named: "emptyprofile")
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        if (userExists()){
            MyUser = getMySuperUser()
        }
        if ((MyUser) != nil){
            OrpheeApi().getFriends(MyUser.id, completion: { (response) in
                for elem in response{
                    do {
                        let user = try User.decode(elem)
                        if (user.id == self.user.id){
                            self.isFriend = true
                            self.askButton.setTitle("Ajouté", forState: .Normal)
                            return
                        }
                    } catch let error {
                        print(error)
                    }
                }
            })
        }
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
            if ((MyUser) != nil){
                if !MyUser.likes.isEmpty{
                    for i in 0 ..< MyUser.likes.count{
                        if (arrayCreations[indexPath.row].id == MyUser.likes[i]){
                            cell.heartImg.image = UIImage(named: "heartfill")
                            break
                        }else{
                            cell.heartImg.image = UIImage(named: "heart")
                        }
                    }
                }
            }
            cell.likeButton.addTarget(self, action: #selector(UserTableViewController.likeButtonTapped(_:)), forControlEvents: .TouchUpInside)
            cell.likeButton.tag = indexPath.row
            cell.commentButton.addTarget(self, action: #selector(UserTableViewController.commentButtonTapped(_:)), forControlEvents: .TouchUpInside)
            cell.commentButton.tag = indexPath.row
            cell.createButton.addTarget(self, action: #selector(UserTableViewController.createButtonTapped(_:)), forControlEvents: .TouchUpInside)
            return cell
        }
        return UITableViewCell()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("toCreation", sender: indexPath.row)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toCreation"){
            if let controller = segue.destinationViewController as? CreationViewController{
                controller.creation = arrayCreations[sender as! Int]
            }
        }
    }

    func likeButtonTapped(sender: UIButton){
        if ((MyUser) != nil){
            OrpheeApi().like(arrayCreations[sender.tag].id, token: MyUser.token!, completion: { (response) in
                print(response)
                if (response as! String == "liked"){
                    self.MyUser.likes.append(self.arrayCreations[sender.tag].id)
                    sender.setImage(UIImage(named: "heartfill"), forState: .Normal)
                }
                if (response as! String == "disliked"){
                    let index = self.MyUser.likes.indexOf(self.arrayCreations[sender.tag].id)
                    self.MyUser.likes.removeAtIndex(index!)
                    sender.setImage(UIImage(named: "heart"), forState: .Normal)
                }
                saveUser(self.MyUser)
            })
        }else{
            callPopUp()
        }
    }

    func commentButtonTapped(sender: UIButton){
        print("comment")
        if ((MyUser) != nil){
            performSegueWithIdentifier("toCreation", sender: sender.tag)
        }else{
            callPopUp()
        }
    }

    func createButtonTapped(sender: UIButton){
        print("create")
    }

    //PopUp Login

    func callPopUp(){
        let alertView = SCLAlertView()
        alertView.addButton("S'inscrire / Se connecter", target:self, selector:#selector(UserTableViewController.goToRegister))
        alertView.showSuccess("Orphée", subTitle: "Tu n'es pas encore inscrit ? Rejoins-nous !")
    }

    func goToRegister(){
        performSegueWithIdentifier("toLogin", sender: nil)
    }

    @IBAction func askFriend(sender: AnyObject) {
        if ((MyUser) != nil){
            if (self.isFriend == false){
            OrpheeApi().addFriend(MyUser.token!, id: user.id!) { (response) in
                if (response as! String == "ok"){
                    self.isFriend = true
                    self.askButton.setTitle("Ajouté", forState: .Normal)
                }else{
                    print("ask error")
                }
            }
            }else{
                OrpheeApi().removeFriend(user.id!, token: MyUser.token!) { (response) in
                    if (response as! String == "ok"){
                        self.isFriend = false
                        self.askButton.setTitle("Ajouter", forState: .Normal)
                    }else{
                        print("remove error")
                    }
                }
            }
        }
    }
}
