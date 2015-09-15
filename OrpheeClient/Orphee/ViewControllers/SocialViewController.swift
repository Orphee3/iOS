//
//  SocialViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 27/06/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class SocialViewController: UITableViewController{
    var userDic: [JSON] = []
    var offset = 0
    var size = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsers(offset, size: size)
        tableView.registerNib(UINib(nibName: "FluxCustomCell", bundle: nil), forCellReuseIdentifier: "FluxCell")
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func refresh(sender:AnyObject){
        self.userDic = []
        getUsers(0, size: size)
        self.refreshControl!.endRefreshing()
    }
    
    func getUsers(offset: Int, size: Int){
        print("JE VAIS GET")
        Alamofire.request(.GET, "http://163.5.84.242:3000/api/user?offset=\(offset)&size=\(size)").responseJSON{request, response, json in
            if let newJson = JSON(json.value!).array{
                self.userDic += newJson
            }
            self.offset += self.size
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (!userDic.isEmpty){
            return userDic.count
        }
        else{
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("CELLULE")
        let cell: FluxCustomCell! = tableView.dequeueReusableCellWithIdentifier("FluxCell") as? FluxCustomCell
        cell.nameProfile.text = userDic[indexPath.section]["username"].string
        cell.addFriendButton.addTarget(self, action: "addFriend:", forControlEvents: .TouchUpInside)
        cell.addFriendButton.tag = indexPath.section
        
        //layout
        cell.layer.shadowOffset = CGSizeMake(-0.2, 0.2)
        cell.layer.shadowRadius = 1
        cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).CGPath
        cell.layer.shadowOpacity = 0.2
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.preservesSuperviewLayoutMargins = false;
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func addFriend(sender: UIButton){
        if var _ = NSUserDefaults.standardUserDefaults().objectForKey("token"){
            print("y a un token")
            let id = userDic[sender.tag]["_id"].string!
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token")!
            let headers = [
                "Authorization": "Bearer \(token)"
            ]
            Alamofire.request(.GET, "http://163.5.84.242:3000/api/askfriend/\(id)", headers: headers).responseJSON{
                request, response, json in
                if (response?.statusCode == 200){
                    print("FRIEND ASKED : \(json)")
                    let nameOfFriend = self.userDic[sender.tag]["username"].string!
                    self.alertViewForMsg("\(nameOfFriend) va recevoir votre demande d'amitié.")
                }
                else if (response?.statusCode == 500){
                    self.alertViewForMsg("Une erreur est survenue lors de votre demande.")
                }
            }
        }
        else{
            print("no token")
        }
        print("friend added")
    }
    
    func alertViewForMsg(msg: String){
        let alertView = UIAlertView(title: "Requête envoyée", message: msg , delegate: self, cancelButtonTitle: "Ok")
        alertView.alertViewStyle = .Default
        alertView.show()
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.section)
        if (indexPath.section == offset - 1){
            getUsers(offset, size: size)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "profile", bundle: nil)
        let loginView = storyboard.instantiateViewControllerWithIdentifier("profileView") as! ProfileUserTableViewController
        loginView.idUser = userDic[indexPath.section]["_id"].string!
        self.navigationController?.pushViewController(loginView, animated: true)
    }
}