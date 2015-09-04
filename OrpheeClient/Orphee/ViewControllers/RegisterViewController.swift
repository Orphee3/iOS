//
//  RegisterViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 27/06/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class RegisterViewController: UIViewController {
    @IBOutlet var loginTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func sendInfosToServer(){
        if (!loginTextField.text!.isEmpty && !passwordTextField.text!.isEmpty){
            print("ça passeé", appendNewline: false);
            let param = [
                "name": "\(loginTextField.text)",
                "username": "\(loginTextField.text)",
                "password": "\(passwordTextField.text)"
            ]
            Alamofire.request(.POST, "https://orpheeapi.herokuapp.com/api/register/", parameters: param, encoding: .JSON).responseJSON { (req, res, json, error) in
                if(error != nil) {
                    NSLog("Error: \(error)")
                    print(req)
                    print(res)
                }
                else {
                    print("Success")
                    var json = JSON(json!)
                    NSUserDefaults.standardUserDefaults().setObject(json["token"].string, forKey: "token")
                    print(json)
                    self.performSegueWithIdentifier("registerOk", sender: nil)
                }
            }
        }
        else{
            let alertView = UIAlertView(title: "Erreur", message: "Tous les champs ne sont pas correctement remplis.", delegate: self, cancelButtonTitle: "Ok")
            alertView.alertViewStyle = .Default
            alertView.show()
        }
    }

    @IBAction func registerButtonPressed(sender: AnyObject) {
        print("coucou", appendNewline: false);
        sendInfosToServer()
    }
}