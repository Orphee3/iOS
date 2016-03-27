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
    var MyUser: mySuperUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if (userExists()){
            MyUser = getMySuperUser()
        }
        OrpheeApi().getPopularCreations(0, size: 50) { (creations) -> () in
            self.arrayCreations = []
            for elem in creations{
                do {
                    let creation = try Creation.decode(elem)
                    self.arrayCreations.append(creation)
                } catch let error {
                    print(error)
                }
            }
            self.arrayCreations = self.arrayCreations.sort({ $0.dateCreation > $1.dateCreation })
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
                    for i in 0 ..< MyUser.likes.count{
                        if (arrayCreations[indexPath.row].id == MyUser.likes[i]){
                            cell.likeButton.setImage(UIImage(named: "heartfill"), forState: .Normal)
                            break
                        }else{
                            cell.likeButton.setImage(UIImage(named: "heart"), forState: .Normal)
                        }
                    }
                }
            }
            cell.likeButton.addTarget(self, action: #selector(HomeViewController.likeButtonTapped(_:)), forControlEvents: .TouchUpInside)
            cell.likeButton.tag = indexPath.row
            cell.commentButton.addTarget(self, action: #selector(HomeViewController.commentButtonTapped(_:)), forControlEvents: .TouchUpInside)
            cell.commentButton.tag = indexPath.row
            cell.createButton.addTarget(self, action: #selector(HomeViewController.createButtonTapped(_:)), forControlEvents: .TouchUpInside)
            return cell
        }
        return UITableViewCell()
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
    
    func callPopUp(){
        let alertView = SCLAlertView()
        alertView.addButton("S'inscrire / Se connecter", target:self, selector:#selector(HomeViewController.goToRegister))
        alertView.showSuccess("Orphee", subTitle: "Tu n'es pas encore inscrit ? Rejoins-nous !")
    }
    
    func goToRegister(){
        performSegueWithIdentifier("toLogin", sender: nil)
    }
    
    @IBAction func cancelLoginAction(segue:UIStoryboardSegue) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toCreation"){
            if let controller = segue.destinationViewController as? CreationViewController{
                controller.creation = arrayCreations[sender as! Int]
            }
        }
    }
}