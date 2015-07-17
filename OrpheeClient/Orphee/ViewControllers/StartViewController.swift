//
//  StartViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 27/06/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit

class StartViewController: UIViewController {
    @IBOutlet var loginField: UITextField!
    @IBOutlet var mdpField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (13/255.0), green: (71/255.0), blue: (161/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    func checkLoginAndPasswd() {
        if (loginField.text == "jeromin" && mdpField.text == "jeromin"){
            performSegueWithIdentifier("toMenu", sender: nil)
        }
        else{
            let alertView = UIAlertView(title: "Erreur", message: "Vos identifiants sont incorrects.", delegate: self, cancelButtonTitle: "Ok")
            alertView.alertViewStyle = .Default
            alertView.show()

        }
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
       checkLoginAndPasswd()
    }
}