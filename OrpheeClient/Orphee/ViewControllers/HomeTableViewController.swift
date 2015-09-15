//
//  HomeTableViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 05/09/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import AVFoundation


class HomeTableViewController: UITableViewController, AVAudioPlayerDelegate {
    var arrayCreation: [JSON] = []
    var offset = 0
    var size = 6
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "CreationFluxCustomCell", bundle: nil), forCellReuseIdentifier: "creationCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        getPopularCreations(offset, size: size)
    }
    
    func refresh(sender:AnyObject){
        arrayCreation = []
        getPopularCreations(0, size: size)
        self.refreshControl!.endRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    func getPopularCreations(offset: Int, size: Int){
        let url =  "http://163.5.84.242:3000/api/creationPopular?offset=\(offset)&size=\(size)"
        Alamofire.request(.GET, url).responseJSON{request, response, json in
            print("POPULAR CREATION : \(json.value)")
            if let newJson = JSON(json.value!).array{
                self.arrayCreation += newJson
                print("USERDIC : \(self.arrayCreation)")
                self.offset += self.size
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (arrayCreation.isEmpty){
            return 0
        }
        else{
            return arrayCreation.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: CreationFluxCustomCell! = tableView.dequeueReusableCellWithIdentifier("creationCell") as? CreationFluxCustomCell
        cell.nameProfileCreator.text = arrayCreation[indexPath.section]["creator"][0]["name"].string
        cell.nameCreation.text = arrayCreation[indexPath.section]["name"].string
        cell.idCreation = arrayCreation[indexPath.section]["_id"].string
        cell.idCreator = arrayCreation[indexPath.section]["creator"][0]["_id"].string
        cell.urlCreation = arrayCreation[indexPath.section]["url"].string
        if let picture = arrayCreation[indexPath.section]["creator"][0]["picture"].string {
            cell.imgProfileCreator.sd_setImageWithURL(NSURL(string: picture), placeholderImage: UIImage(named: "emptygrayprofile"))
        }
        cell.playCreation.addTarget(self, action: "playCreation:", forControlEvents: .TouchUpInside)
        cell.playCreation.tag = indexPath.section
        cell.accessProfileButton.addTarget(self, action: "accessProfile:", forControlEvents: .TouchUpInside)
        cell.accessProfileButton.tag = indexPath.section
        cell = layoutCell(cell)
        return cell
    }
    
    func layoutCell(cell: CreationFluxCustomCell) -> CreationFluxCustomCell{
        cell.layer.shadowOffset = CGSizeMake(-0.2, 0.2)
        cell.layer.shadowRadius = 1
        cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).CGPath
        cell.layer.shadowOpacity = 0.2
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.preservesSuperviewLayoutMargins = false;
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func playCreation(sender: UIButton){
        print("touched PLAY CREATION")
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        print("finished playing \(flag)")
    }
    
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        print("\(error!.localizedDescription)")
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "creationDetail", bundle: nil)
        let loginView = storyboard.instantiateViewControllerWithIdentifier("detailView") as! DetailsCreationTableViewController
        loginView.idCreation = arrayCreation[indexPath.section]["_id"].string!
        self.navigationController?.pushViewController(loginView, animated: true)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == offset){
            getPopularCreations(offset, size: size)
        }
    }
    
    func accessProfile(sender: UIButton){
        let storyboard = UIStoryboard(name: "profile", bundle: nil)
        let loginView = storyboard.instantiateViewControllerWithIdentifier("profileView") as! ProfileUserTableViewController
        loginView.idUser = arrayCreation[sender.tag]["creator"][0]["_id"].string!
        self.navigationController?.pushViewController(loginView, animated: true)
    }
}