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

class SocialViewController: UIViewController{
    @IBOutlet var tableView: UITableView!
    var arrayUser: [User] = []
    var offset = 0
    var size = 6
    var searchDisplay: UISearchController!
    var searchBar: UISearchBar!
    var user = User!()
    
    var popupView: NotConnectedView!
    var blurView: UIVisualEffectView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("myUser") as? NSData {
            user = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! User
        }
        prepareSearchingDisplay()
        
        if (OrpheeReachability().isConnected()){
            getUsers(offset, size: size)
        }
        tableView.registerNib(UINib(nibName: "FluxCustomCell", bundle: nil), forCellReuseIdentifier: "FluxCell")
        self.tableView.addPullToRefresh({ [weak self] in
            //refresh code
            if (OrpheeReachability().isConnected()){
                self!.arrayUser = []
                self!.offset = 0
                self!.getUsers(self!.offset, size: self!.size)
                self?.tableView.stopPullToRefresh()
            }else{
                self?.tableView.stopPullToRefresh()
            }
            })
    }
    
    func getUsers(offset: Int, size: Int){
        if (OrpheeReachability().isConnected()){
            OrpheeApi().getUsers(offset, size: size, completion: {(response) in
                dispatch_async(dispatch_get_main_queue()) {
                    self.arrayUser = response
                    self.tableView.reloadData()
                }
                self.offset += self.size
            })
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
        popupView = NotConnectedView.instanceFromNib()
        popupView.layer.cornerRadius = 8
        popupView.layer.shadowOffset = CGSize(width: 30, height: 30)
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.frame = CGRectMake(0, 0, self.tableView.frame.width, self.tableView.frame.height)
        self.tableView.addSubview(blurView)
        popupView.center = CGPointMake(self.blurView.frame.size.width / 2, self.blurView.frame.size.height / 2)
        popupView.goToLogin.addTarget(self, action: "sendToLogin:", forControlEvents: .TouchUpInside)
        popupView.closeButton.addTarget(self, action: "closePopUpLogin:", forControlEvents: .TouchUpInside)
        blurView.addSubview(popupView)
    }
    
    func closePopUpLogin(sender: UIButton){
        popupView.removeFromSuperview()
        blurView.removeFromSuperview()
    }
    
    func sendToLogin(sender: UIButton){
        let storyboard = UIStoryboard(name: "LoginRegister", bundle: nil)
        let loginView: UINavigationController = storyboard.instantiateViewControllerWithIdentifier("askLogin") as! UINavigationController
        self.presentViewController(loginView, animated: true, completion: nil)
    }
}

extension SocialViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "profile", bundle: nil)
        let profileView = storyboard.instantiateViewControllerWithIdentifier("profileView") as! ProfileUserTableViewController
        profileView.user = arrayUser[indexPath.row]
        self.navigationController?.pushViewController(profileView, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!arrayUser.isEmpty){
            return arrayUser.count
        }
        else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: FluxCustomCell! = tableView.dequeueReusableCellWithIdentifier("FluxCell") as? FluxCustomCell
        cell.putInGraphic(arrayUser[indexPath.row])
        cell.addFriendButton.addTarget(self, action: "addFriend:", forControlEvents: .TouchUpInside)
        cell.addFriendButton.tag = indexPath.row
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == arrayUser.count){
            if (OrpheeReachability().isConnected()){
                getUsers(self.offset, size: self.size)
            }
        }
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