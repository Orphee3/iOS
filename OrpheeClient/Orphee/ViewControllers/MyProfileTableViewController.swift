//
//  MyProfileTableViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 13/08/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire

class MyProfileTableViewController: UITableViewController{
    var userProfileDic: JSON!
    var loginView: UINavigationController!
    @IBOutlet var imgLogin: UIImageView!
    var loginButton: UIButton!
    @IBOutlet var nameProfile: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        getPhoto()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        if var _ = NSUserDefaults.standardUserDefaults().objectForKey("token"){
            print("y a un token")
            //getPhoto()
            getName()
        }
        else{
            print("no token")
            prepareViewForLogin()
        }
    }
    
    func getName(){
        nameProfile.text = NSUserDefaults.standardUserDefaults().objectForKey("userName") as? String
    }
    
    func getPhoto(){
        let photo = NSUserDefaults.standardUserDefaults().objectForKey("imgProfile")
        if let tmp = photo{
            Alamofire.request(.GET, tmp as! String).response() {
                (_, _, data, _) in
                let image = UIImage(data: data!)
                self.imgLogin.image = image
                self.tableView.reloadData()
            }
        }
        else{
            imgLogin.image = UIImage(named: "emptyprofile")
        }
    }
    
    func prepareViewForLogin(){
        imgLogin = UIImageView(image: UIImage(named: "imgLogin"))
        imgLogin.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        self.view.addSubview(imgLogin)
        loginButton = UIButton(frame: CGRectMake(self.view.frame.width / 2 - 50, self.view.frame.height - 150, 100, 30))
        loginButton.setTitle("Allons-y !", forState: UIControlState.Normal)
        loginButton.addTarget(self, action: "sendToLogin:", forControlEvents: .TouchUpInside)
        self.view.addSubview(loginButton)
    }
    
    func sendToLogin(sender: UIButton){
        let storyboard = UIStoryboard(name: "LoginRegister", bundle: nil)
        loginView = storyboard.instantiateViewControllerWithIdentifier("askLogin") as! UINavigationController
        self.presentViewController(loginView, animated: true, completion: nil)
    }
    
    @IBAction func deconection(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("token")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        if let _ = loginButton{
            loginButton.removeFromSuperview()
            imgLogin.removeFromSuperview()
        }
    }
}