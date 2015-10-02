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

class SocialViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating{
    var userDic: [JSON] = []
    var offset = 0
    var size = 3
    var spinner: UIActivityIndicatorView!
    var searchDisplay: UISearchController!
    var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareSearchingDisplay()
        
        createActivityIndicatorView()
        spinner.startAnimating()
        getUsers(offset, size: size)
        tableView.registerNib(UINib(nibName: "FluxCustomCell", bundle: nil), forCellReuseIdentifier: "FluxCell")
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func prepareSearchingDisplay(){
        searchDisplay = UISearchController(searchResultsController: nil)
        searchDisplay.searchResultsUpdater = self
        searchDisplay.dimsBackgroundDuringPresentation = false
        searchDisplay.hidesNavigationBarDuringPresentation = false;
        searchDisplay.searchBar.sizeToFit()
        self.navigationItem.titleView = self.searchDisplay.searchBar;
        definesPresentationContext = true
    }
    
    func refresh(sender:AnyObject){
        self.userDic = []
        getUsers(0, size: size)
        self.refreshControl!.endRefreshing()
    }
    
    func createActivityIndicatorView(){
        spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        spinner.frame = CGRectMake(self.view.frame.width / 2, self.view.frame.height / 2, 50, 50)
        spinner.center = CGPointMake(self.view.frame.width / 2, self.view.frame.height / 2)
        self.view.addSubview(spinner)
    }
    
    func getUsers(offset: Int, size: Int){
        Alamofire.request(.GET, "http://163.5.84.242:3000/api/user?offset=\(offset)&size=\(size)").responseJSON{request, response, json in
            if let newJson = JSON(json.value!).array{
                self.userDic += newJson
            }
            self.offset += self.size
            dispatch_async(dispatch_get_main_queue()) {
                self.spinner.stopAnimating()
                self.tableView.reloadData()
            }
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!userDic.isEmpty){
            return userDic.count
        }
        else{
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("CELLULE")
        let cell: FluxCustomCell! = tableView.dequeueReusableCellWithIdentifier("FluxCell") as? FluxCustomCell
        cell.nameProfile.text = userDic[indexPath.row]["username"].string
        cell.addFriendButton.addTarget(self, action: "addFriend:", forControlEvents: .TouchUpInside)
        cell.addFriendButton.tag = indexPath.row
        if let picture = userDic[indexPath.row]["picture"].string {
            cell.imgProfile.sd_setImageWithURL(NSURL(string: picture), placeholderImage: UIImage(named: "emptygrayprofile"))
        }
        
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "profile", bundle: nil)
        let loginView = storyboard.instantiateViewControllerWithIdentifier("profileView") as! ProfileUserTableViewController
        loginView.idUser = userDic[indexPath.row]["_id"].string!
        self.navigationController?.pushViewController(loginView, animated: true)
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if !searchController.active {
            return
        }
        
        let text = searchController.searchBar.text
        
        if (text?.characters.count > 2){
            print("search")
            print("http://163.5.84.242:3000/api/user/\(text!)/name")
            Alamofire.request(.GET, "http://163.5.84.242:3000/api/user/\(text!)/name").responseJSON{request, response, json in
                print(json.value)
                dispatch_async(dispatch_get_main_queue()) {
                    self.userDic = JSON(json.value!).array!
                    self.tableView.reloadData()
                }
            }
        }else if (text?.characters.count == 0){
            getUsers(0, size: 10)
        }
    }
}