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
import SDWebImage
import AVFoundation

class HomeTableViewController: UITableViewController{
    var arrayCreation: [Creation] = []
    var arrayUser: [User] = []
    var offset = 0
    var size = 10
    var user = User!()
    var spinner: UIActivityIndicatorView!
    
    var player: pAudioPlayer!;
    var audioIO: AudioGraph = AudioGraph();
    var session: AudioSession = AudioSession();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let data = NSUserDefaults.standardUserDefaults().objectForKey("myUser") as? NSData {
            user = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! User
        }
        tableView.infiniteScrollIndicatorStyle = .White
        tableView.infiniteScrollIndicatorMargin = 40
        tableView.addInfiniteScrollWithHandler({(scrollView) -> Void in
            self.getPopularCreations(self.offset, size: self.size)
            self.tableView.reloadData()
            scrollView.finishInfiniteScroll()
        })
        
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
        
        self.getPopularCreations(offset, size: size)
    }
    
    func refresh(sender:AnyObject){
        arrayCreation = []
        arrayUser = []
        offset = 0
        getPopularCreations(offset, size: size)
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
    
    func getPopularCreations(offset: Int, size: Int){
        OrpheeApi().getPopularCreations(offset, size: size, completion: {(creations, users) ->() in
            self.arrayCreation += creations
            self.arrayUser += users
            dispatch_async(dispatch_get_main_queue()){
                self.spinner.stopAnimating()
                self.refreshControl!.endRefreshing()
                self.tableView.reloadData()
            }
            self.offset += self.size
        })
    }
    
    func playCreation(sender: UIButton){
        let destination =
        Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory,
            domain: .UserDomainMask)
        Alamofire.download(.GET, arrayCreation[sender.tag].url, destination: destination) .progress{ bytesRead, totalBytesRead, totalBytesExpectedToRead in
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
    
    func stopPlayCreation(sender: UIButton) {
        self.player.stop()
    }

    func accessProfile(sender: UIButton){
        let storyboard = UIStoryboard(name: "profile", bundle: nil)
        let profileView = storyboard.instantiateViewControllerWithIdentifier("profileView") as! ProfileUserTableViewController
        profileView.user = arrayUser[sender.tag]
        self.navigationController?.pushViewController(profileView, animated: true)
    }
}

extension HomeTableViewController{
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (arrayCreation.isEmpty){
            return 0
        }
        else{
            return arrayCreation.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: CreationFluxCustomCell! = tableView.dequeueReusableCellWithIdentifier("creationCell") as? CreationFluxCustomCell
        
        let user = self.arrayUser[indexPath.row]
        let creation = self.arrayCreation[indexPath.row]
        
        cell.putInGraphic(creation, user: user)
        cell.accessProfileButton.addTarget(self, action: "accessProfile:", forControlEvents: .TouchUpInside)
        cell.accessProfileButton.tag = indexPath.row
        cell.accessCommentButton.tag = indexPath.row
        cell.accessCommentButton.addTarget(self, action: "commentPushed:", forControlEvents: .TouchUpInside)
        cell.likeButton.addTarget(self, action: "likePushed:", forControlEvents: .TouchUpInside)
        cell.likeButton.tag = indexPath.row
        return cell
    }

    func likePushed(sender: UIButton){
        print("like")
        if (user != nil){
            OrpheeApi().like(arrayCreation[sender.tag].id, token: user.token, completion: { (response) -> () in
                print(response)
                if (response as! String == "ok"){
                    sender.setImage(UIImage(named: "heartfill"), forState: .Normal)
                }
                if (response as! String == "liked"){
                    OrpheeApi().dislike(self.arrayCreation[sender.tag].id, token: self.user.token, completion: {(response) -> () in
                        if (response as! String == "ok"){
                            sender.setImage(UIImage(named: "heart"), forState: .Normal)
                        }
                    })
                }
            })
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "creationDetail", bundle: nil)
        let commentView = storyboard.instantiateViewControllerWithIdentifier("detailView") as! DetailsCreationTableViewController
        commentView.creation = arrayCreation[indexPath.row]
        self.navigationController?.pushViewController(commentView, animated: true)
    }

    func commentPushed(sender: UIButton){
        let storyboard = UIStoryboard(name: "creationDetail", bundle: nil)
        let commentView = storyboard.instantiateViewControllerWithIdentifier("detailView") as! DetailsCreationTableViewController
        commentView.creation = arrayCreation[sender.tag]
        self.navigationController?.pushViewController(commentView, animated: true)
    }
}