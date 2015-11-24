//
//  MessengerViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 20/08/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import DZNEmptyDataSet
import Alamofire

class MessengerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource{
    
    @IBOutlet var tableView: UITableView!
    
    var arrayRooms: [Room] = []
    var user = User!()
    var blurView: UIVisualEffectView!
    var popupView: NotConnectedView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "RoomCell", bundle: nil), forCellReuseIdentifier: "RoomCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("myUser") as? NSData {
            user = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! User
        }
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        self.tableView.tableFooterView = UIView()
        if (user != nil){
            getRooms()
        }else{
            prepareViewForLogin()
        }
        self.tableView.addPullToRefresh({ [weak self] in
            //refresh code
            if (OrpheeReachability().isConnected()){
//                self!.arrayUser = []
//                self!.offset = 0
//                self!.getUsers(self!.offset, size: self!.size)
                self?.tableView.stopPullToRefresh()
            }else{
                self?.tableView.stopPullToRefresh()
            }
            })
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        let image = UIImage(named: "orpheeLogoRoundSmall")
        return image
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Aucune conversation pour le moment"
        let attributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 19)!]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Pour commencer à discuter avec d'autres compositeurs, cliquez sur le boutton ci-dessous."
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraph.alignment = NSTextAlignment.Center
        
        let attributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 14)!, NSForegroundColorAttributeName: UIColor.lightGrayColor(), NSParagraphStyleAttributeName: paragraph]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 17)!]
        return NSAttributedString(string: "Commencer une conversation", attributes: attributes)
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        print("start")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (arrayRooms.isEmpty){
            return 0
        }else{
            return arrayRooms.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RoomCell") as! RoomCell
        cell.layoutCell(arrayRooms[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("toConversation", sender: arrayRooms[indexPath.row])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toConversation"{
            let conv = segue.destinationViewController as! ConversationViewController
            let room = sender as! Room
            conv.senderId = room.peoplesId[1]
            conv.userName = room.peoples[1]
        }
    }
    
    func prepareViewForLogin(){
        popupView = NotConnectedView.instanceFromNib()
        popupView.layer.cornerRadius = 8
        popupView.layer.shadowOffset = CGSize(width: 30, height: 30)
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.frame = CGRectMake(0, 0, self.tableView.frame.width, self.tableView.frame.height)
        self.tableView.addSubview(blurView)
        popupView.goToLogin.addTarget(self, action: "sendToLogin:", forControlEvents: .TouchUpInside)
        popupView.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2) - (popupView.frame.size.width / 2))
        popupView.closeButton.hidden = true
        blurView.addSubview(popupView)
    }
    
    func sendToLogin(sender: UIButton){
        let storyboard = UIStoryboard(name: "LoginRegister", bundle: nil)
        let loginView: UINavigationController = storyboard.instantiateViewControllerWithIdentifier("askLogin") as! UINavigationController
        self.presentViewController(loginView, animated: true, completion: nil)
    }
    
    func getRooms(){
        let headers = [
            "Authorization": "Bearer \(user.token)"
        ]
        Alamofire.request(.GET, "http://163.5.84.242:3000/api/user/\(user.id)/rooms", headers: headers).responseJSON{request, response, json in
            if (response?.statusCode == 200){
                print(json.value)
                if let array = json.value as! Array<Dictionary<String, AnyObject>>?{
                    for elem in array{
                        self.arrayRooms.append(Room(RoomElement: elem))
                    }
                    self.tableView.reloadData()
                }
                else{
                    
                }
            }
        }
    }
}