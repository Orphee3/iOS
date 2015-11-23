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
import DZNEmptyDataSet

class HomeTableViewController: UITableViewController{
    var arrayCreation: [Creation] = []
    var arrayUser: [User] = []
    var offset = 0
    var size = 10
    var user = User!()
    
    var player: pAudioPlayer!;
    var audioIO: AudioGraph = AudioGraph();
    var session: AudioSession = AudioSession();
    
    var isRefreshing = false
    
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
        
        self.getPopularCreations(offset, size: size)
    }
    
    func refresh(sender:AnyObject){
        if (OrpheeReachability().isConnected() && !isRefreshing){
            arrayCreation = []
            arrayUser = []
            offset = 0
            getPopularCreations(offset, size: size)
            isRefreshing = true
        }else{
            isRefreshing = false
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    func getPopularCreations(offset: Int, size: Int){
        if (OrpheeReachability().isConnected()){
            OrpheeApi().getPopularCreations(offset, size: size, completion: {(creations, users) ->() in
                self.arrayCreation += creations
                self.arrayUser += users
                dispatch_async(dispatch_get_main_queue()){
                    self.refreshControl!.endRefreshing()
                    self.isRefreshing = false
                    self.tableView.reloadData()
                }
                self.offset += self.size
            })
        }
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
        if (user != nil ){
            if (OrpheeReachability().isConnected()){
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
        }else{
            prepareViewForLogin()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(user != nil){
            let storyboard = UIStoryboard(name: "creationDetail", bundle: nil)
            let commentView = storyboard.instantiateViewControllerWithIdentifier("detailView") as! DetailsCreationTableViewController
            commentView.creation = arrayCreation[indexPath.row]
            commentView.userCreation = arrayUser[indexPath.row]
            self.navigationController?.pushViewController(commentView, animated: true)
        }else{
            prepareViewForLogin()
        }
    }
    
    func commentPushed(sender: UIButton){
        if (user != nil){
            let storyboard = UIStoryboard(name: "creationDetail", bundle: nil)
            let commentView = storyboard.instantiateViewControllerWithIdentifier("detailView") as! DetailsCreationTableViewController
            commentView.creation = arrayCreation[sender.tag]
            commentView.userCreation = arrayUser[sender.tag]
            self.navigationController?.pushViewController(commentView, animated: true)
        }else{
            prepareViewForLogin()
        }
    }
}

extension HomeTableViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource{
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        let image = UIImage(named: "orpheeLogoRoundSmall")
        return image
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Aucune données n'est disponible :("
        let attributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 19)!]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Vérifiez que vous êtes bien connecté à internet, par 3G/4G ou Wifi !"
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraph.alignment = NSTextAlignment.Center
        
        let attributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 14)!, NSForegroundColorAttributeName: UIColor.lightGrayColor(), NSParagraphStyleAttributeName: paragraph]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func emptyDataSetShouldDisplay(scrollView: UIScrollView!) -> Bool {
        return true
    }
}