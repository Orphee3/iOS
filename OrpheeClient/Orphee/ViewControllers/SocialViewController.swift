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

class SocialViewController: UITableViewController{
    var arrayUser: [User] = []
    var offset = 0
    var size = 6
    var searchDisplay: UISearchController!
    var searchBar: UISearchBar!
    var user = User!()
    
    var isRefreshing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("myUser") as? NSData {
            user = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! User
        }
        prepareSearchingDisplay()
        
        tableView.infiniteScrollIndicatorStyle = .White
        tableView.infiniteScrollIndicatorMargin = 40
        tableView.addInfiniteScrollWithHandler({(scrollView) -> Void in
            self.getUsers(self.offset, size: self.size)
            scrollView.finishInfiniteScroll()
        })
        getUsers(offset, size: size)
        tableView.registerNib(UINib(nibName: "FluxCustomCell", bundle: nil), forCellReuseIdentifier: "FluxCell")
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func refresh(sender:AnyObject){
        if (OrpheeReachability().isConnected() && !isRefreshing){
            self.isRefreshing = true
            self.arrayUser = []
            self.offset = 0
            getUsers(self.offset, size: size)
        }else{
            self.refreshControl?.endRefreshing()
        }
    }
    
    func getUsers(offset: Int, size: Int){
        
        OrpheeApi().getUsers(offset, size: size, completion: {(response) in
            self.offset += self.size
            dispatch_async(dispatch_get_main_queue()) {
                self.isRefreshing = false
                self.refreshControl!.endRefreshing()
                self.tableView.reloadData()
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
    }
    
    func addFriend(sender: UIButton){
        if (user != nil){
            OrpheeApi().addFriend(user.token, id: arrayUser[sender.tag].id, completion: {(response) -> () in
                if (response as! String == "ok"){
                    self.alertViewForMsg("\(self.arrayUser[sender.tag].name) va recevoir votre demande d'amitié.")
                    sender.setImage(UIImage(named: "adduserfill"), forState: .Normal)
                }
                else if (response as! String == "error"){
                    self.alertViewForMsg("Une erreur est survenue lors de votre demande.")
                }
            })
        }else{
            prepareViewForLogin()
        }
    }
    
    func alertViewForMsg(msg: String){
        let alertView = UIAlertView(title: "Requête envoyée", message: msg , delegate: self, cancelButtonTitle: "Ok")
        alertView.alertViewStyle = .Default
        alertView.show()
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

extension SocialViewController{
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "profile", bundle: nil)
        let profileView = storyboard.instantiateViewControllerWithIdentifier("profileView") as! ProfileUserTableViewController
        profileView.user = arrayUser[indexPath.row]
        self.navigationController?.pushViewController(profileView, animated: true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!arrayUser.isEmpty){
            return arrayUser.count
        }
        else{
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: FluxCustomCell! = tableView.dequeueReusableCellWithIdentifier("FluxCell") as? FluxCustomCell
        cell.putInGraphic(arrayUser[indexPath.row])
        cell.addFriendButton.addTarget(self, action: "addFriend:", forControlEvents: .TouchUpInside)
        cell.addFriendButton.tag = indexPath.row
        return cell
    }
}

extension SocialViewController: UISearchControllerDelegate, UISearchResultsUpdating{
    func prepareSearchingDisplay(){
        searchDisplay = UISearchController(searchResultsController: nil)
        searchDisplay.searchResultsUpdater = self
        searchDisplay.dimsBackgroundDuringPresentation = false
        searchDisplay.hidesNavigationBarDuringPresentation = false;
        searchDisplay.searchBar.sizeToFit()
        self.navigationItem.titleView = self.searchDisplay.searchBar;
        definesPresentationContext = true
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if !searchController.active {
            getUsers(0, size: self.size)
            return
        }
        
        let text = searchController.searchBar.text
        
        if (text?.characters.count > 2){
            self.arrayUser = []
            print("search")
            print("http://163.5.84.242:3000/api/user/\(text!)/name")
            Alamofire.request(.GET, "http://163.5.84.242:3000/api/user/\(text!)/name").responseJSON{request, response, json in
                dispatch_async(dispatch_get_main_queue()) {
                    if let array = json.value as! Array<Dictionary<String, AnyObject>>?{
                        for elem in array{
                            self.arrayUser.append(User(User: elem))
                            print("search found")
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        }else if (text?.characters.count == 0){
            getUsers(0, size: 10)
        }
    }
}