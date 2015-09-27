//
//  ProfileUserTableViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 06/09/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire
import SDWebImage

class ProfileUserTableViewController: UITableViewController {
    var user: User!
    var arrayCreations: [Creation] = []
    
    @IBOutlet var nameProfile: UILabel!
    @IBOutlet var nbLikeProfile: UILabel!
    @IBOutlet var nbCreationProfile: UILabel!
    @IBOutlet var imgProfile: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "CreationProfileCustomCell", bundle: nil), forCellReuseIdentifier: "creationProfileCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        nameProfile.text = user.name
        if let picture = user.picture {
            imgProfile.sd_setImageWithURL(NSURL(string: picture), placeholderImage: UIImage(named: "emptygrayprofile"))
        }
        getInfoUser()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (arrayCreations.isEmpty){
            return 0
        }
        else{
            return arrayCreations.count
        }
    }
    
    func getInfoUser(){
        Alamofire.request(.GET, "http://163.5.84.242:3000/api/user/\(self.user.id)/creation").responseJSON{request, response, json in
            if let array = json.value as! Array<Dictionary<String, AnyObject>>?{
                for elem in array{
                    self.arrayCreations.append(Creation(Creation: elem))
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func likeCreation(sender: UIButton){
        //        Alamofire.request(.POST, <#T##URLString: URLStringConvertible##URLStringConvertible#>){
        //
        //        }
    }
    
    func commentPushed(sender: UIButton){
        let storyboard = UIStoryboard(name: "creationDetail", bundle: nil)
        let commentView = storyboard.instantiateViewControllerWithIdentifier("detailView") as! DetailsCreationTableViewController
        commentView.creation = arrayCreations[sender.tag]
        self.navigationController?.pushViewController(commentView, animated: true)
    }
}

extension ProfileUserTableViewController{
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: CreationProfileCustomCell! = tableView.dequeueReusableCellWithIdentifier("creationProfileCell") as? CreationProfileCustomCell
        
        cell.putInGraphic(arrayCreations[indexPath.section])
        
        nbCreationProfile.text = String(self.arrayCreations.count)
        cell.commentButton.tag = indexPath.section
        cell.likeButton.tag = indexPath.section
        cell.likeButton.addTarget(self, action: "likeCreation:", forControlEvents: .TouchUpInside)
        cell.commentButton.addTarget(self, action: "commentPushed:", forControlEvents: .TouchUpInside)
        return cell
    }
}