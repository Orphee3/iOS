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

class HomeTableViewController: UITableViewController{
    var arrayCreation: [JSON] = []
    var offset = 0
    var size = 10
    var sectionTab = 0
    
    var spinner: UIActivityIndicatorView!
    
    var player: pAudioPlayer!;
    var audioIO: AudioGraph = AudioGraph();
    var session: AudioSession = AudioSession();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "CreationFluxCustomCell", bundle: nil), forCellReuseIdentifier: "creationCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        session.setupSession(&audioIO);
        audioIO.createAudioGraph();
        audioIO.configureAudioGraph();
        audioIO.startAudioGraph();
        
        player = GenericPlayer(graph: audioIO, session: session);
        
        createActivityIndicatorView()
        spinner.startAnimating()
        getPopularCreations(offset, size: size, route: self.sectionTab)
    }
    
    func refresh(sender:AnyObject){
        arrayCreation = []
        offset = 0
        getPopularCreations(offset, size: size, route: self.sectionTab)
        self.refreshControl!.endRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    func createActivityIndicatorView(){
        spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        spinner.frame = CGRectMake(self.view.frame.width / 2, self.view.frame.height / 2, 50, 50)
        spinner.center = CGPointMake(self.view.frame.width / 2, self.view.frame.height / 2)
        self.view.addSubview(spinner)
    }
    
    func getPopularCreations(offset: Int, size: Int, route: Int){
   //     let myId = NSUserDefaults.standardUserDefaults().objectForKey("myId") as! String
        let urlPopular = "http://163.5.84.242:3000/api/creationPopular?offset=\(offset)&size=\(size)"
   //     let urlFriends = "http://163.5.84.242:3000/api/user/\(myId)/flux?offset=\(offset)&size=\(size)"
        var url: String!
        if(route == 0){
            url = urlPopular
        }
//        else{
//            url = urlFriends
//        }
        Alamofire.request(.GET, url).responseJSON{request, response, json in
            print("POPULAR CREATION : \(json.value)")
            if let newJson = JSON(json.value!).array{
                self.arrayCreation += newJson
                print("USERDIC : \(self.arrayCreation)")
                self.offset += self.size
                print("OFFSET: \(self.offset)")
                dispatch_async(dispatch_get_main_queue()) {
                    self.spinner.stopAnimating()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        offset = 0
        getPopularCreations(0, size: 5, route: sender.selectedSegmentIndex)
        sectionTab = sender.selectedSegmentIndex
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
        let title =  arrayCreation[indexPath.section]["name"].string
        cell.nameCreation.text =  title!.substringWithRange(Range<String.Index>(start: title!.startIndex.advancedBy(0), end: title!.endIndex.advancedBy(-4)))
        cell.idCreation = arrayCreation[indexPath.section]["_id"].string
        cell.idCreator = arrayCreation[indexPath.section]["creator"][0]["_id"].string
        cell.urlCreation = arrayCreation[indexPath.section]["url"].string
        if let picture = arrayCreation[indexPath.section]["creator"][0]["picture"].string {
            cell.imgProfileCreator.sd_setImageWithURL(NSURL(string: picture), placeholderImage: UIImage(named: "emptygrayprofile"))
        }
       // cell.nbComments.text = String(arrayCreation[indexPath.section]["nbComments"])
       // cell.likesCreation.text = String(arrayCreation[indexPath.section]["nbLikes"])
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
        let destination =
        Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory,
            domain: .UserDomainMask)
        Alamofire.download(.GET, arrayCreation[sender.tag]["url"].string!, destination: destination) .progress{ bytesRead, totalBytesRead, totalBytesExpectedToRead in
            print(totalBytesRead)
            }.responseJSON{request, response, json in
                print(response)
                if (response?.statusCode == 200){
                    if let urlDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL!{
                        let path = response?.suggestedFilename
                        let data = NSData(contentsOfURL: urlDirectory.URLByAppendingPathComponent(path!))
                        self.player.play(data!)
                    }
                }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "creationDetail", bundle: nil)
        let loginView = storyboard.instantiateViewControllerWithIdentifier("detailView") as! DetailsCreationTableViewController
        loginView.idCreation = arrayCreation[indexPath.section]["_id"].string!
        self.navigationController?.pushViewController(loginView, animated: true)
    }
    
    func accessProfile(sender: UIButton){
        let storyboard = UIStoryboard(name: "profile", bundle: nil)
        let loginView = storyboard.instantiateViewControllerWithIdentifier("profileView") as! ProfileUserTableViewController
        loginView.idUser = arrayCreation[sender.tag]["creator"][0]["_id"].string!
        self.navigationController?.pushViewController(loginView, animated: true)
    }
}