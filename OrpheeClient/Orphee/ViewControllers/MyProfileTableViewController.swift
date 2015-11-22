//
//  MyProfileTableViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 13/08/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class MyProfileTableViewController: UITableViewController{
    var user: User!
    var arrayCreations: [Creation] = []
    var loginView: UINavigationController!
    @IBOutlet var nbCreations: UILabel!
    @IBOutlet var imgLogin: UIImageView!
    @IBOutlet var nameProfile: UILabel!
    var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "CreationProfileCustomCell", bundle: nil), forCellReuseIdentifier: "creationProfileCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("myUser") as? NSData {
            self.user = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! User
            self.nameProfile.text = self.user.name
            if let picture = self.user.picture{
                self.imgLogin.sd_setImageWithURL(NSURL(string: picture), placeholderImage: UIImage(named: "emptygrayprofile"))
            }else{
                self.imgLogin.image = UIImage(named: "emptygrayprofile")
            }
            getCreations()
        }
        else{
            prepareViewForLogin()
        }
    }
    
    func getCreations(){
        Alamofire.request(.GET, "http://163.5.84.242:3000/api/user/\(self.user.id)/creation").responseJSON{request, response, json in
            if let array = json.value as! Array<Dictionary<String, AnyObject>>?{
                for elem in array{
                    self.arrayCreations.append(Creation(Creation: elem))
                }
                self.nbCreations.text = String(self.arrayCreations.count)
                self.tableView.reloadData()
            }
        }
    }
    
    func prepareViewForLogin(){
//        imgLogin = UIImageView(image: UIImage(named: "imgLogin"))
//        imgLogin.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
//        self.view.addSubview(imgLogin)
//        loginButton = UIButton(frame: CGRectMake(self.view.frame.width / 2 - 50, self.view.frame.height - 150, 100, 30))
//        loginButton.setTitle("Allons-y !", forState: UIControlState.Normal)
//        loginButton.addTarget(self, action: "sendToLogin:", forControlEvents: .TouchUpInside)
//        self.view.addSubview(loginButton)
    }
    
    func sendToLogin(sender: UIButton){
        let storyboard = UIStoryboard(name: "LoginRegister", bundle: nil)
        loginView = storyboard.instantiateViewControllerWithIdentifier("askLogin") as! UINavigationController
        self.presentViewController(loginView, animated: true, completion: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        if let _ = loginButton{
            loginButton.removeFromSuperview()
            imgLogin.removeFromSuperview()
        }
    }
}

extension MyProfileTableViewController{
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (arrayCreations.isEmpty){
            return 0
        }
        else{
            return arrayCreations.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: CreationProfileCustomCell! = tableView.dequeueReusableCellWithIdentifier("creationProfileCell") as? CreationProfileCustomCell
        
        cell.putInGraphic(arrayCreations[indexPath.section])
        
        cell.likeButton.tag = indexPath.section
        cell.likeButton.addTarget(self, action: "likeCreation:", forControlEvents: .TouchUpInside)
        cell.commentButton.tag = indexPath.section
        cell.commentButton.addTarget(self, action: "commentPushed:", forControlEvents: .TouchUpInside)
        return cell
    }
    
    func commentPushed(sender: UIButton){
        let storyboard = UIStoryboard(name: "creationDetail", bundle: nil)
        let commentView = storyboard.instantiateViewControllerWithIdentifier("detailView") as! DetailsCreationTableViewController
        commentView.creation = arrayCreations[sender.tag]
        self.navigationController?.pushViewController(commentView, animated: true)
    }
}