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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsers()
        tableView.registerNib(UINib(nibName: "FluxCustomCell", bundle: nil), forCellReuseIdentifier: "FluxCell")
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
        Alamofire.request(.GET, "http://163.5.84.242:3000/api/user?offset=0&size=15").responseJSON{request, response, json in
            //print(response)
            //print(json)
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
        return 10
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
        print("friend added")
        let id = userDic[sender.tag]["_id"].string!
        let token = NSUserDefaults.standardUserDefaults().objectForKey("token")!
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request(.GET, "http://163.5.84.242:3000/api/askfriend/\(id)", headers: headers).responseJSON{
            request, response, json in
            if (response?.statusCode == 200){
                let nameOfFriend = self.userDic[sender.tag]["username"].string!
                self.alertViewForMsg("\(nameOfFriend) va recevoir votre demande d'amitié.")
            }
        }
    }
    
    func alertViewForMsg(msg: String){
        let alertView = UIAlertView(title: "Requête envoyée", message: msg , delegate: self, cancelButtonTitle: "Ok")
        alertView.alertViewStyle = .Default
        alertView.show()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
}