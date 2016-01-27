//
//  DetailsCreationTableViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 10/09/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class DetailsCreationTableViewController: UITableViewController{
    var creation: Creation!
    var arrayComments: [Comment] = []
    var user = User!()
    var userCreation = User!()
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var commentTextField: UITextField!
    
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var profileName: UILabel!
    @IBOutlet var nbLikes: UILabel!
    @IBOutlet var creationTitle: UILabel!
    @IBOutlet var nbComments: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("myUser") as? NSData {
            user = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! User
        }
        tableView.registerNib(UINib(nibName: "commentCellView", bundle: nil), forCellReuseIdentifier: "commentcell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.commentTextField.delegate = self
        
        getComments()
        layoutCreation()
    }
    
    func refresh(sender:AnyObject){
        if (OrpheeReachability().isConnected()){
            arrayComments = []
            getComments()
            self.layoutCreation()
            self.tableView.reloadData()
            self.refreshControl!.endRefreshing()
        }else{
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    func layoutCreation(){
        if let title = creation.name{
            self.creationTitle.text = title
        }
        if let nbComment = creation.nbCommments{
            self.nbComments.text = String(nbComment)
        }
        
        if let nbLikes = creation.nbLikes{
            self.nbLikes.text = String(nbLikes)
        }
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.width / 2
        if let picture = userCreation.picture{
            self.profilePicture.sd_setImageWithURL(NSURL(string: picture), placeholderImage: UIImage(named: "emptygrayprofile"))
        }else{
            self.profilePicture.image = UIImage(named: "emptygrayprofile")
        }
        if let name = userCreation.name{
            self.profileName.text = name
        }
    }
    
    func getComments(){
        OrpheeApi().getComments(creation.id, completion: {(response) -> () in
            print(response)
            self.arrayComments = response
            self.tableView.reloadData()
        })
    }
    
    @IBAction func sendComment(sender: AnyObject) {
        if (commentTextField.text != nil && OrpheeReachability().isConnected()){
            print(user.token)
            print(user.name)
            print(user.picture)
            print(creation.id)
            print(user.id)
            print(commentTextField.text)
            OrpheeApi().sendComment(user.token, name: user.name, picture: user.picture, creationId: creation.id, userId: user.id, message: commentTextField.text!, completion: {(response) ->() in
                            print("lol")
                self.arrayComments.insert(response as! Comment, atIndex: 0)
                self.commentTextField.text = ""
                self.nbComments.text = String(self.creation.nbCommments + 1)
                OrpheeApi().notify(self.user.token, creationId: self.creation.id, completion: {(response) in
                    
                })
                self.tableView.reloadData()
            })
        }
        textFieldShouldReturn(self.commentTextField)
    }
    
    @IBAction func like(sender: AnyObject) {
        if (user != nil && OrpheeReachability().isConnected()){
            OrpheeApi().like(creation.id, token: user.token, completion: { (response) -> () in
                print(response)
                if (response as! String == "ok"){
                    sender.setImage(UIImage(named: "heartfill"), forState: .Normal)
                    self.nbLikes.text = String(self.creation.nbLikes + 1)
                }
                if (response as! String == "liked"){
                    OrpheeApi().dislike(self.creation.id, token: self.user.token, completion: {(response) -> () in
                        if (response as! String == "ok"){
                            sender.setImage(UIImage(named: "heart"), forState: .Normal)
                            self.nbLikes.text = String(self.creation.nbLikes)
                        }
                    })
                }
            })
        }
    }

}

extension DetailsCreationTableViewController: UITextFieldDelegate{
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (arrayComments.isEmpty){
            return 0
        }
        else{
            return arrayComments.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: commentCellView! = tableView.dequeueReusableCellWithIdentifier("commentcell") as? commentCellView
        cell.msgUser.text = arrayComments[indexPath.row].message
        cell.nameUser.text = arrayComments[indexPath.row].user
        if let picture = arrayComments[indexPath.row].picture {
            cell.imgUser.sd_setImageWithURL(NSURL(string: picture), placeholderImage: UIImage(named: "emptygrayprofile"))
        }
        return cell
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}