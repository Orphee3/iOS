//
//  ProfileTableViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 21/03/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView

class ProfileTableViewController: UITableViewController {
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var labelNameProfile: UILabel!
    var myUser: mySuperUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if (userExists()){
            myUser = getMySuperUser()
            print(myUser.name)
        }else{
            callPopUp()
            print("no user registered")
        }
    }
    
    func callPopUp(){
        
        let alertView = SCLAlertView()
        alertView.addButton("S'inscrire / Se connecter", target:self, selector:Selector("goToRegister"))
        alertView.addButton("Fermer", target: self, selector: Selector("closePopUp"))
        alertView.showCloseButton = false
        alertView.showSuccess("Button View", subTitle: "This alert view has buttons")
    }
    
    func goToRegister(){
        performSegueWithIdentifier("toLogin", sender: nil)
    }
    
    func closePopUp(){
        performSegueWithIdentifier("toHome", sender: nil)
    }
}