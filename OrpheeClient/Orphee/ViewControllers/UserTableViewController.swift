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
    
    var id: String!
    var user: User!
    var arrayCreations: [Creation] = []
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
            cell.likeButton.addTarget(self, action: "likeButtonTapped:", forControlEvents: .TouchUpInside)
            cell.commentButton.addTarget(self, action: "commentButtonTapped:", forControlEvents: .TouchUpInside)
            cell.createButton.addTarget(self, action: "createButtonTapped:", forControlEvents: .TouchUpInside)
            return cell
        }
        return UITableViewCell()
    }
    
    func likeButtonTapped(sender: UIButton){
        print("liked")
        callPopUp()
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
}