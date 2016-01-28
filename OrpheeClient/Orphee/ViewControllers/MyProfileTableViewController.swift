//
//  MyProfileTableViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 13/08/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class MyProfileTableViewController: UICollectionViewController{
    var user: User!
    var arrayCreations: [Creation] = []
    var loginButton: UIButton!
    
    var popupView: NotConnectedView!
    var blurView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView!.registerNib(UINib(nibName: "CreationProfileCustomCell", bundle: nil), forCellWithReuseIdentifier: "creationProfileCell")
        collectionView?.registerNib(UINib(nibName: "HeaderProfileView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderProfileView")
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("myUser") as? NSData {
            self.user = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! User
            if (popupView != nil){
                popupView.removeFromSuperview()
                blurView.removeFromSuperview()
            }
            getCreations()
        }
        else{
            prepareViewForLogin()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        print("VIEWWILLAPPEAR")
        navigationController!.navigationBar.barTintColor = UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        navigationController!.tabBarItem.badgeValue = nil;
    }
    
    func getCreations(){
        Alamofire.request(.GET, "http://163.5.84.242:3000/api/user/\(self.user.id)/creation").responseJSON{request, response, json in
            if let array = json.value as! Array<Dictionary<String, AnyObject>>?{
                for elem in array{
                    self.arrayCreations.append(Creation(Creation: elem))
                }
                //self.nbCreations.text = String(self.arrayCreations.count)
                self.collectionView!.reloadData()
            }
        }
    }
    
    func prepareViewForLogin(){
        popupView = NotConnectedView.instanceFromNib()
        popupView.layer.cornerRadius = 8
        popupView.layer.shadowOffset = CGSize(width: 30, height: 30)
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.frame = CGRectMake(0, 0, self.collectionView!.frame.width, self.collectionView!.frame.height)
        self.collectionView!.addSubview(blurView)
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
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
    }
}

extension MyProfileTableViewController{
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (arrayCreations.isEmpty){
            return 0
        }
        else{
            return arrayCreations.count
        }
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(self.view.frame.width, 90)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: CreationProfileCustomCell! = collectionView.dequeueReusableCellWithReuseIdentifier("creationProfileCell", forIndexPath: indexPath) as? CreationProfileCustomCell
        cell.putInGraphic(arrayCreations[indexPath.row])
        
        cell.commentButton.tag = indexPath.row
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: "likeCreation:", forControlEvents: .TouchUpInside)
        cell.commentButton.addTarget(self, action: "commentPushed:", forControlEvents: .TouchUpInside)
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderProfileView", forIndexPath: indexPath) as! HeaderProfileView
            headerView.putInGraphic(user)
            headerView.nbCreationProfile.text = String(self.arrayCreations.count)
            return headerView
        default:
            
            assert(false, "Unexpected element kind")
        }
    }
    
    func commentPushed(sender: UIButton){
        let storyboard = UIStoryboard(name: "creationDetail", bundle: nil)
        let commentView = storyboard.instantiateViewControllerWithIdentifier("detailView") as! DetailsCreationTableViewController
        commentView.creation = arrayCreations[sender.tag]
        commentView.userCreation = user
        self.navigationController?.pushViewController(commentView, animated: true)
    }
}