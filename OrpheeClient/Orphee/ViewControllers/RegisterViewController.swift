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
            print("ça passe");
            let param = [
                "name": "\(loginTextField.text)",
                "username": "\(loginTextField.text)",
                "password": "\(passwordTextField.text)"
            ]
            Alamofire.request(.POST, "http://163.5.84.242:3000/api/register", parameters: param, encoding: .JSON)
                .responseJSON { req, res, json in
                    if (res?.statusCode == 200){
                        var json = JSON(json.value!)
                        NSUserDefaults.standardUserDefaults().setObject(json["token"].string, forKey: "token")
                        self.performSegueWithIdentifier("registerOk", sender: nil)
                    }else{
                        if (res?.statusCode == 409){
                            self.alertViewForErrors("Cet utilisateur existe déjà")
                        }
                    }
            }
        }
        else{
            alertViewForErrors("Tous les champs ne sont pas correctement remplis.")
        }
    }
    
    func alertViewForErrors(msg: String){
        let alertView = UIAlertView(title: "Erreur", message: msg , delegate: self, cancelButtonTitle: "Ok")
        alertView.alertViewStyle = .Default
        alertView.show()
    }
    
    @IBAction func registerButtonPressed(sender: AnyObject) {
        sendInfosToServer()
    }
}