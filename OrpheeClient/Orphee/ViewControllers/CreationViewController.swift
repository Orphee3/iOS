//
//  CreationViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 01/03/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import NextGrowingTextView

class CreationViewController: UIViewController{
    var creation: Creation!
    var arrayComments: [Comment] = []
    var MyUser: mySuperUser!
    
    @IBOutlet var likeButton: UIButton!
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var inputContainerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var growingTextView: NextGrowingTextView!
    @IBOutlet weak var imgCreator: UIImageView!
    @IBOutlet weak var nameCreator: UILabel!
    @IBOutlet var nameCreation: UILabel!
    @IBOutlet var likeImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (userExists()){
            MyUser = getMySuperUser()
            for i in 0 ..< MyUser.likes.count{
                if (creation.id == MyUser.likes[i]){
                    likeImage.image = UIImage(named: "heartfill")
                }
            }
        }
        self.nameCreation.text = creation.name
        if let picture = creation.creator[0].picture{
            imgCreator.kf_setImageWithURL(NSURL(string: picture)!, placeholderImage: UIImage(named: "emptyprofile"))
        }else{
            imgCreator.image = UIImage(named: "emptyprofile")
        }
        nameCreator.text = creation.creator[0].name
        getComment()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(CreationViewController.keyboardWillAppear(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(CreationViewController.keyboardWillDisappear(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        self.growingTextView.layer.cornerRadius = 4
        self.growingTextView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        self.commentTableView.rowHeight = 80
        self.commentTableView.estimatedRowHeight = UITableViewAutomaticDimension
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(CreationViewController.refresh(_:)), forControlEvents: .ValueChanged)
        commentTableView.addSubview(refreshControl)
    }
    
    func getComment(){
        arrayComments = []
        OrpheeApi().getComments(creation.id) { (response) in
            print(response)
            for elem in response{
                do {
                    let comment = try Comment.decode(elem)
                    print("ok")
                    self.arrayComments.append(comment)
                } catch let error {
                    print(error)
                }
            }
            self.commentTableView.reloadData()
        }
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        getComment()
        refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillAppear(notification: NSNotification){
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        self.view.frame.origin = CGPointMake(0, self.view.frame.origin.y - keyboardFrame.size.height + inputContainerView.frame.size.height)
    }
    
    func keyboardWillDisappear(notification: NSNotification){
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        self.view.frame.origin = CGPointMake(0, self.view.frame.origin.y + keyboardFrame.size.height - inputContainerView.frame.size.height)
    }
    
    @IBAction func handleSendButton(sender: AnyObject) {
        if (self.growingTextView.text == ""){
        }
        else{
            if ((MyUser) != nil){
                OrpheeApi().sendComment(MyUser.token!, name: MyUser.name, picture: MyUser.picture!, creationId: creation.id, userId: creation.creator[0].id, message: self.growingTextView.text, completion: { (response) in
                    print(response)
                })
                self.growingTextView.text = ""
            }
        }
        self.view.endEditing(true)
    }
    
    
    @IBAction func like(sender: AnyObject) {
        
    }
}

extension CreationViewController: UITableViewDelegate, UITableViewDataSource{    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (arrayComments.isEmpty){
            return 0
        }else{
            return arrayComments.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("commentTableViewCell") as? CommentTableViewCell{
            cell.fillCell(arrayComments[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
}