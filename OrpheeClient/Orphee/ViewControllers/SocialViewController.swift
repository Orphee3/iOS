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
    var arrayUser: [User] = []
    var offset = 0
    var size = 6
    var spinner: UIActivityIndicatorView!
    var searchDisplay: UISearchController!
    var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareSearchingDisplay()
        
        tableView.infiniteScrollIndicatorStyle = .White
        tableView.infiniteScrollIndicatorMargin = 40
        tableView.addInfiniteScrollWithHandler({(scrollView) -> Void in
            self.getUsers(self.offset, size: self.size)
            scrollView.finishInfiniteScroll()
        })
        
        createActivityIndicatorView()
        spinner.startAnimating()
        getUsers(offset, size: size)
        tableView.registerNib(UINib(nibName: "FluxCustomCell", bundle: nil), forCellReuseIdentifier: "FluxCell")
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func refresh(sender:AnyObject){
        self.arrayUser = []
        self.offset = 0
        getUsers(self.offset, size: size)
    }
    
    func createActivityIndicatorView(){
        spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        spinner.frame = CGRectMake(self.view.frame.width / 2, self.view.frame.height / 2, 50, 50)
        spinner.center = CGPointMake(self.view.frame.width / 2, self.view.frame.height / 2)
        self.view.addSubview(spinner)
    }
    
    func getUsers(offset: Int, size: Int){
        Alamofire.request(.GET, "http://163.5.84.242:3000/api/user?offset=\(offset)&size=\(size)").responseJSON{request, response, json in
            print(json.value)
            if let array = json.value as! Array<Dictionary<String, AnyObject>>?{
                for elem in array{
                    self.arrayUser.append(User(User: elem))
                }
                self.offset += self.size
                dispatch_async(dispatch_get_main_queue()) {
                    self.spinner.stopAnimating()
                    self.refreshControl!.endRefreshing()
                    self.tableView.reloadData()
                }
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
    
    func addFriend(sender: UIButton){
        if var _ = NSUserDefaults.standardUserDefaults().objectForKey("token"){
            print("y a un token")
            let id = arrayUser[sender.tag].id
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token")!
            let headers = [
                "Authorization": "Bearer \(token)"
            ]
            Alamofire.request(.GET, "http://163.5.84.242:3000/api/askfriend/\(id)", headers: headers).responseJSON{
                request, response, json in
                if (response?.statusCode == 200){
                    print("FRIEND ASKED : \(json)")
                    self.alertViewForMsg("\(self.arrayUser[sender.tag].name) va recevoir votre demande d'amitié.")
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