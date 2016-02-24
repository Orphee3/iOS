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

class HomeViewController: UITableViewController{
    var arrayCreations: [Creation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func cancelLoginAction(segue:UIStoryboardSegue) {
        
    }
}