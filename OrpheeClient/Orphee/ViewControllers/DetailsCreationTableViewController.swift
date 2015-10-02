//
//  DetailsCreationTableViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 10/09/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class DetailsCreationTableViewController: UITableViewController , UITextFieldDelegate{
    var idCreation: String = ""
    var creationArray: JSON = []
    var commentsArray: [JSON] = []
    
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var commentTextField: UITextField!
    @IBOutlet var nbComments: UILabel!
    @IBOutlet var titleCreation: UILabel!
    @IBOutlet var nbLikes: UILabel!
    
    var player: pAudioPlayer!;
    var audioIO: AudioGraph = AudioGraph();
    var session: AudioSession = AudioSession();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "commentCellView", bundle: nil), forCellReuseIdentifier: "commentcell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.commentTextField.delegate = self
        getInfosCreation()
        getComments()
        layoutCreation()
        
        session.setupSession(&audioIO);
        audioIO.createAudioGraph();
        audioIO.configureAudioGraph();
        audioIO.startAudioGraph();
        player = GenericPlayer(graph: audioIO, session: session);
        var instru = PresetMgr().getMelodicInstrumentFromSoundBank(46, path: NSBundle.mainBundle().pathForResource("32MbGMStereo", ofType: "sf2")!, isSoundFont: true)!
        audioIO.loadInstrumentFromInstrumentData(&instru);
    }
    
    func refresh(sender:AnyObject){
        commentsArray = []
        getInfosCreation()
        getComments()
        self.layoutCreation()
        self.tableView.reloadData()
        print(commentsArray.count)
        self.refreshControl!.endRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    func layoutCreation(){
        nbComments.text = "0"
        nbLikes.text = "0"
       // let title = creationArray["name"].string!
        titleCreation.text = "Mickael"
        //title.substringWithRange(Range<String.Index>(start: title.startIndex.advancedBy(0), end: title.endIndex.advancedBy(-4)))
    }
    
    //offset & size
    
    func getInfosCreation(){
        Alamofire.request(.GET, "http://163.5.84.242:3000/api/creation/\(idCreation)").responseJSON{request, response, json in
            print("creation = \(json.value)")
            if (response!.statusCode == 200){
                self.creationArray = JSON(json.value!)
                self.tableView.reloadData()
            }
        }
    }
    
    func getComments(){
        Alamofire.request(.GET, "http://163.5.84.242:3000/api/comment/creation/\(idCreation)").responseJSON{request, response, json in
            print("comments = \(json.value)")
            if (response!.statusCode == 200){
                self.commentsArray = JSON(json.value!).array!
                print(self.commentsArray)
                self.commentsArray = self.commentsArray.reverse()
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func sendComment(sender: AnyObject) {
        if var _ = NSUserDefaults.standardUserDefaults().objectForKey("token"){
            print("y a un token")
            if (commentTextField.text != nil){
                let token = NSUserDefaults.standardUserDefaults().objectForKey("token")!
                let headers = [
                    "Authorization": "Bearer \(token)"
                ]
                let myId = NSUserDefaults.standardUserDefaults().objectForKey("myId") as! String
                let params = [
                    "creation": "\(idCreation)",
                    "creator": "\(myId)",
                    "message": "\(commentTextField.text!)",
                    "parentId": "\(idCreation)"
                ]
                print(params)
                Alamofire.request(.POST, "http://163.5.84.242:3000/api/comment", headers: headers, parameters: params, encoding: .JSON).responseJSON{ request, response, json in
                    var creator = JSON(json.value!)
                    let name = "name"
                    let picture = "picture"
                    let keycreator = "creator"
                    self.commentsArray.insert([
                        "message":"\(self.commentTextField.text!)",
                        "creator": ["name":"\(creator[keycreator][name])", "picture": "\(creator[keycreator][picture])"]
                        ], atIndex: 0)
                    self.commentTextField.text = ""
                    self.tableView.reloadData()
                    Alamofire.request(.GET, "http://163.5.84.242:3000/api/notify/comments/\(self.idCreation)", headers: headers).responseJSON{request, response, json in
                        print("message envoyé")
                    }
                }
            }
            else{
                print("no token")
            }
        }
        
        textFieldShouldReturn(self.commentTextField)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (commentsArray.isEmpty){
            return 0
        }
        else{
            return commentsArray.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: commentCellView! = tableView.dequeueReusableCellWithIdentifier("commentcell") as? commentCellView
        cell.msgUser.text = commentsArray[indexPath.section]["message"].string!
        cell.nameUser.text = commentsArray[indexPath.section]["creator"]["name"].string!
        if let picture = commentsArray[indexPath.section]["creator"]["picture"].string {
            cell.imgUser.sd_setImageWithURL(NSURL(string: picture), placeholderImage: UIImage(named: "emptygrayprofile"))
        }
        return cell
    }
    
    @IBAction func playButtonTouched(sender: AnyObject) {
        print(creationArray["url"].string!)
        let destination =
        Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory,
            domain: .UserDomainMask)
        Alamofire.download(.GET, creationArray["url"].string!, destination: destination) .progress{ bytesRead, totalBytesRead, totalBytesExpectedToRead in
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
    
}