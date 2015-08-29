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

class SocialViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet var tableView: UITableView!
    var userDic: JSON!
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsers()
        tableView.registerNib(UINib(nibName: "FluxCustomCell", bundle: nil), forCellReuseIdentifier: "FluxCell")
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func refresh(sender:AnyObject){
        getUsers()
        self.refreshControl.endRefreshing()
    }
    
    @IBAction func segmentedControlTouched(sender: UISegmentedControl) {
        switch(sender.selectedSegmentIndex){
        case 0:
            print("flux")
        case 1:
            print("profil")
        default:
            break
        }
    }
    
    func getUsers(){
        Alamofire.request(.GET, "http://163.5.84.242:3000/api/user?offset=0&size=50").responseJSON{request, response, json in
            let newJson = JSON(json.value!)
            self.userDic = newJson
            print(self.userDic)
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (13/255.0), green: (71/255.0), blue: (161/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tmp = userDic{
            return tmp.count
        }
        else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: FluxCustomCell! = tableView.dequeueReusableCellWithIdentifier("FluxCell") as? FluxCustomCell
        if(userDic != nil){
            cell.nameProfile.text = userDic[indexPath.row]["username"].string
            cell.addFriendButton.addTarget(self, action: "addFriend:", forControlEvents: .TouchUpInside)
            cell.addFriendButton.tag = indexPath.row
        }
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
            prepareViewForLogin()
        }
        print("friend added")
    }
    
    func alertViewForMsg(msg: String){
        let alertView = UIAlertView(title: "Requête envoyée", message: msg , delegate: self, cancelButtonTitle: "Ok")
        alertView.alertViewStyle = .Default
        alertView.show()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func prepareViewForLogin(){

    }
}