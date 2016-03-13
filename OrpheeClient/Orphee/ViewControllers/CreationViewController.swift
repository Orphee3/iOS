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
    
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var inputContainerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var growingTextView: NextGrowingTextView!
    @IBOutlet weak var imgCreator: UIImageView!
    @IBOutlet weak var nameCreator: UILabel!
    @IBOutlet var nameCreation: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commentTableView.rowHeight = 80
        self.commentTableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.nameCreation.text = creation.name
        if let picture = creation.creator[0].picture{
            imgCreator.kf_setImageWithURL(NSURL(string: picture)!, placeholderImage: UIImage(named: "emptyprofile"))
        }else{
            imgCreator.image = UIImage(named: "emptyprofile")
        }
        nameCreator.text = creation.creator[0].name
        OrpheeApi().getComments(creation.id) { (response) in
            print(response)
            for elem in response{
                do {
                    let comment = try Comment.decode(elem)
                    self.arrayComments.append(comment)
                } catch let error {
                    print(error)
                }
            }
            self.commentTableView.reloadData()
        }
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillAppear:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillDisappear:", name: UIKeyboardWillHideNotification, object: nil)
        
        self.growingTextView.layer.cornerRadius = 4
        self.growingTextView.backgroundColor = UIColor(white: 0.9, alpha: 1)
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
        self.growingTextView.text = ""
        self.view.endEditing(true)
    }
}

extension CreationViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!arrayComments.isEmpty){
            return arrayComments.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("commentTableViewCell") as? CommentTableViewCell{
            cell.fillCell(arrayComments[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
}