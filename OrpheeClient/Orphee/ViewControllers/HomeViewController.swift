//
//  HomeViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 23/02/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView
import Locksmith

class HomeViewController: UITableViewController{
    var arrayCreations: [Creation] = []
    var MyUser: myUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMyUser { (response) in
            self.MyUser = response
            print(self.MyUser.likes)
        }
        OrpheeApi().getPopularCreations(0, size: 50) { (creations) -> () in
            self.arrayCreations = creations
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!self.arrayCreations.isEmpty){
            return self.arrayCreations.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("HomeTableViewCell") as? HomeTableViewCell{
            cell.fillCell(arrayCreations[indexPath.row])
            if ((MyUser) != nil){
                if !MyUser.likes.isEmpty{
                    let i = checkIfLikeExists(arrayCreations[indexPath.row].id, likes: MyUser.likes)
                    if (i == 0){
                        cell.likeButton.setImage(UIImage(named: "heart"), forState: .Normal)
                    }
                    else{
                        cell.likeButton.setImage(UIImage(named: "heartfill"), forState: .Normal)
                    }
                }
            }
            
            cell.likeButton.addTarget(self, action: "likeButtonTapped:", forControlEvents: .TouchUpInside)
            cell.likeButton.tag = indexPath.row
            cell.commentButton.addTarget(self, action: "commentButtonTapped:", forControlEvents: .TouchUpInside)
            cell.createButton.addTarget(self, action: "createButtonTapped:", forControlEvents: .TouchUpInside)
            return cell
        }
        return UITableViewCell()
    }
    
    func checkIfLikeExists(like: String, likes: Array<String>) -> Int{
        var i = 0
        for elem in likes{
            if (elem == like){
                return i
            }
            i += 1
        }
        return 0
    }
    
    func likeButtonTapped(sender: UIButton){
        if ((MyUser) != nil){
            OrpheeApi().like(arrayCreations[sender.tag].id, token: MyUser.token!, completion: { (response) in
                print(response)
                if (response as! String == "liked"){
                    sender.setImage(UIImage(named: "heartfill"), forState: .Normal)
                }
                if (response as! String == "disliked"){
                    sender.setImage(UIImage(named: "heart"), forState: .Normal)
                }
                updateMyUser(self.arrayCreations[sender.tag].id, completion: { (response) in
                    print(response)
                    self.MyUser = response
                })
            })
        }else{
            callPopUp()
        }
    }
    
    func commentButtonTapped(sender: UIButton){
        print("comment")
        callPopUp()
    }
    
    func createButtonTapped(sender: UIButton){
        print("create")
    }
    
    //PopUp Login
    
    func callPopUp(){
        let alertView = SCLAlertView()
        alertView.addButton("S'inscrire / Se connecter", target:self, selector:Selector("goToRegister"))
        alertView.showSuccess("Button View", subTitle: "This alert view has buttons")
    }
    
    func goToRegister(){
        performSegueWithIdentifier("toLogin", sender: nil)
    }
    
    @IBAction func cancelLoginAction(segue:UIStoryboardSegue) {
        
    }
}