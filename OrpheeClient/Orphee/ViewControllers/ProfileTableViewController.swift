//
//  ProfileTableViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 21/03/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView

class ProfileTableViewController: UITableViewController {
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var labelNameProfile: UILabel!
    var myUser: mySuperUser!
    var arrayCreations: [Creation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if (userExists()){
            myUser = getMySuperUser()
            if let picture = myUser.picture{
                imgProfile.kf_setImageWithURL(NSURL(string: picture)!, placeholderImage: UIImage(named: "emptyprofile"))
            }else{
                imgProfile.image = UIImage(named: "emptyprofile")
            }
            labelNameProfile.text = myUser.name
            OrpheeApi().getInfoUserById(myUser.id, completion: { (infoUser) in
                for elem in infoUser{
                    do {
                        let creation = try Creation.decode(elem)
                        self.arrayCreations.append(creation)
                    } catch let error {
                        print(error)
                    }
                }
                self.tableView.reloadData()
            })
        }else{
            callPopUp()
            print("no user registered")
        }
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!arrayCreations.isEmpty){
            return arrayCreations.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("ProfileCell") as? ProfileCellTableViewController{
            cell.fillCell(arrayCreations[indexPath.row])
            cell.likeButton.addTarget(self, action: #selector(ProfileTableViewController.likeButtonTapped(_:)), forControlEvents: .TouchUpInside)
            cell.likeButton.tag = indexPath.row
            cell.commentButton.addTarget(self, action: #selector(ProfileTableViewController.commentButtonTapped(_:)), forControlEvents: .TouchUpInside)
            cell.commentButton.tag = indexPath.row
            cell.createButton.addTarget(self, action: #selector(ProfileTableViewController.createButtonTapped(_:)), forControlEvents: .TouchUpInside)
            cell.createButton.tag = indexPath.row
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if ((myUser) != nil){
            performSegueWithIdentifier("toCreation", sender: indexPath.row)
        }
    }
    
    func likeButtonTapped(sender: UIButton){
        print("liked")
        if ((myUser) != nil){
            OrpheeApi().like(arrayCreations[sender.tag].id, token: myUser.token!, completion: { (response) in
                print(response)
                if (response as! String == "liked"){
                    self.myUser.likes.append(self.arrayCreations[sender.tag].id)
                    //sender.setImage(UIImage(named: "heartfill"), forState: .Normal)
                }
                if (response as! String == "disliked"){
                    let index = self.myUser.likes.indexOf(self.arrayCreations[sender.tag].id)
                    self.myUser.likes.removeAtIndex(index!)
                    //sender.setImage(UIImage(named: "heart"), forState: .Normal)
                }
                saveUser(self.myUser)
            })
        }
    }
    
    func commentButtonTapped(sender: UIButton){
        print("comment")
        if ((myUser) != nil){
            performSegueWithIdentifier("toCreation", sender: sender.tag)
        }
    }
    
    func createButtonTapped(sender: UIButton){
        print("create")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toCreation"){
            if let controller = segue.destinationViewController as? CreationViewController{
                controller.creation = arrayCreations[sender as! Int]
            }
        }
    }
    
    func callPopUp(){
        let alertView = SCLAlertView()
        alertView.addButton("S'inscrire / Se connecter", target:self, selector:#selector(ProfileTableViewController.goToRegister))
        alertView.addButton("Fermer", target: self, selector: #selector(ProfileTableViewController.closePopUp))
        alertView.showCloseButton = false
        alertView.showSuccess("Button View", subTitle: "This alert view has buttons")
    }
    
    func goToRegister(){
        performSegueWithIdentifier("toLogin", sender: nil)
    }
    
    func closePopUp(){
        performSegueWithIdentifier("toHome", sender: nil)
    }
}