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
    var idUser = ""
    var arrayUser = JSON([])
    var arrayCreations = JSON([])
    
    @IBOutlet var nameProfile: UILabel!
    @IBOutlet var nbLikeProfile: UILabel!
    @IBOutlet var nbCreationProfile: UILabel!
    @IBOutlet var imgProfile: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "CreationProfileCustomCell", bundle: nil), forCellReuseIdentifier: "creationProfileCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        print(idUser)
        nbLikeProfile.text = "0"
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
        if (!idUser.isEmpty){
            
            Alamofire.request(.GET, "http://163.5.84.242:3000/api/user/\(idUser)").responseJSON{request, response, json in
                print("INFO USER : \(json.value)")
                print(response)
                self.arrayUser = JSON(json.value!)
                self.setInfoUser()
                Alamofire.request(.GET, "http://163.5.84.242:3000/api/user/\(self.idUser)/creation").responseJSON{request, response, json in
                    print("CREATION USER : \(json.value)")
                    self.arrayCreations = JSON(json.value!)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func setInfoUser(){
        nameProfile.text = arrayUser["name"].string
        if let picture = arrayUser["picture"].string {
            imgProfile.sd_setImageWithURL(NSURL(string: picture), placeholderImage: UIImage(named: "emptygrayprofile"))
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: CreationProfileCustomCell! = tableView.dequeueReusableCellWithIdentifier("creationProfileCell") as? CreationProfileCustomCell
        
        cell.nameCreation.text = self.arrayCreations[indexPath.section]["name"].string
        cell.nbCommentCreation.text = String(self.arrayCreations[indexPath.section]["comments"].count)
        cell.nbLikeCreation.text = "0"
        nbCreationProfile.text = String(self.arrayCreations.count)
        cell.commentButton.tag = indexPath.section
        cell.likeButton.tag = indexPath.section
        cell.likeButton.addTarget(self, action: "likeCreation:", forControlEvents: .TouchUpInside)
        cell.commentButton.addTarget(self, action: "commentPushed:", forControlEvents: .TouchUpInside)
        cell = layoutCell(cell)
        return cell
    }
    
    func likeCreation(sender: UIButton){
//        Alamofire.request(.POST, <#T##URLString: URLStringConvertible##URLStringConvertible#>){
//            
//        }
    }
    
    func commentPushed(sender: UIButton){
        let storyboard = UIStoryboard(name: "creationDetail", bundle: nil)
        let loginView = storyboard.instantiateViewControllerWithIdentifier("detailView") as! DetailsCreationTableViewController
        loginView.idCreation = arrayCreations[sender.tag]["_id"].string!
        self.navigationController?.pushViewController(loginView, animated: true)
    }
    
    func layoutCell(cell: CreationProfileCustomCell) -> CreationProfileCustomCell{
        cell.layer.shadowOffset = CGSizeMake(-0.2, 0.2)
        cell.layer.shadowRadius = 1
        cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).CGPath
        cell.layer.shadowOpacity = 0.2
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.preservesSuperviewLayoutMargins = false;
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
}