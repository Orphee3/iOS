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

class MessengerViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource{
    var arrayRooms: [Room] = []
    var user = User!()
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
        getRooms()
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (arrayRooms.isEmpty){
            return 0
        }else{
            return arrayRooms.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RoomCell") as! RoomCell
        cell.layoutCell(arrayRooms[indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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