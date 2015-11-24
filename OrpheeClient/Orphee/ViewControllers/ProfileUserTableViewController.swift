//
//  ProfileUserTableViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 06/09/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SDWebImage

class ProfileUserTableViewController: UITableViewController {
    var user: User!
    var arrayCreations: [Creation] = []
    var myProfile = User!()
    
    @IBOutlet var nameProfile: UILabel!
    @IBOutlet var nbLikeProfile: UILabel!
    @IBOutlet var nbCreationProfile: UILabel!
    @IBOutlet var imgProfile: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("myUser") as? NSData {
            myProfile = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! User
        }
        tableView.registerNib(UINib(nibName: "CreationProfileCustomCell", bundle: nil), forCellReuseIdentifier: "creationProfileCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        nameProfile.text = user.name
        if let picture = user.picture {
            imgProfile.sd_setImageWithURL(NSURL(string: picture), placeholderImage: UIImage(named: "emptygrayprofile"))
        }
        imgProfile.layer.cornerRadius = self.imgProfile.frame.width / 2
        getInfoUser()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    func getInfoUser(){
        Alamofire.request(.GET, "http://163.5.84.242:3000/api/user/\(self.user.id)/creation").responseJSON{request, response, json in
            if let array = json.value as! Array<Dictionary<String, AnyObject>>?{
                for elem in array{
                    self.arrayCreations.append(Creation(Creation: elem))
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func likeCreation(sender: UIButton){
        if (myProfile != nil){
            if (OrpheeReachability().isConnected()){
                OrpheeApi().like(arrayCreations[sender.tag].id, token: myProfile.token, completion: { (response) -> () in
                    print(response)
                    if (response as! String == "ok"){
                        sender.setImage(UIImage(named: "heartfill"), forState: .Normal)
                    }
                    if (response as! String == "liked"){
                        OrpheeApi().dislike(self.arrayCreations[sender.tag].id, token: self.user.token, completion: {(response) -> () in
                            if (response as! String == "ok"){
                                sender.setImage(UIImage(named: "heart"), forState: .Normal)
                            }
                        })
                    }
                })
            }
        }else{
            prepareViewForLogin()
        }
    }
    
    func commentPushed(sender: UIButton){
        if (myProfile != nil){
            let storyboard = UIStoryboard(name: "creationDetail", bundle: nil)
            let commentView = storyboard.instantiateViewControllerWithIdentifier("detailView") as! DetailsCreationTableViewController
            commentView.creation = arrayCreations[sender.tag]
            self.navigationController?.pushViewController(commentView, animated: true)
        }else{
            prepareViewForLogin()
        }
    }
    
    func prepareViewForLogin(){
        let popupView: NotConnectedView = NotConnectedView.instanceFromNib()
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.frame = self.tableView.frame
        self.tableView.addSubview(blurView)
        popupView.goToLogin.addTarget(self, action: "sendToLogin:", forControlEvents: .TouchUpInside)
        popupView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2)
        blurView.addSubview(popupView)
    }
    
    func sendToLogin(sender: UIButton){
        let storyboard = UIStoryboard(name: "LoginRegister", bundle: nil)
        let loginView: UINavigationController = storyboard.instantiateViewControllerWithIdentifier("askLogin") as! UINavigationController
        self.presentViewController(loginView, animated: true, completion: nil)
    }
}

extension ProfileUserTableViewController{
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (arrayCreations.isEmpty){
            return 0
        }
        else{
            return arrayCreations.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: CreationProfileCustomCell! = tableView.dequeueReusableCellWithIdentifier("creationProfileCell") as? CreationProfileCustomCell
        
        cell.putInGraphic(arrayCreations[indexPath.row])
        
        nbCreationProfile.text = String(self.arrayCreations.count)
        cell.commentButton.tag = indexPath.row
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: "likeCreation:", forControlEvents: .TouchUpInside)
        cell.commentButton.addTarget(self, action: "commentPushed:", forControlEvents: .TouchUpInside)
        return cell
    }
}