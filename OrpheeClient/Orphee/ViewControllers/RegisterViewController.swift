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
    var spin: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func sendInfosToServer(){
        if (!loginTextField.text!.isEmpty && !passwordTextField.text!.isEmpty){
            patientView()
            let param = [
                "name": "\(loginTextField.text!)",
                "username": "\(loginTextField.text!)",
                "password": "\(passwordTextField.text!)"
            ]
            let url = "http://163.5.84.242:3000/api/register"
            Alamofire.request(.POST, url, parameters: param, encoding: .JSON).responseJSON { request, response, json in
                if (response?.statusCode == 500){
                    self.alertViewForErrors("Erreur de connexion, veuillez réessayer plus tard")
                }
                else if(response?.statusCode == 409){
                    self.alertViewForErrors("Utilisateur déjà existant.")
                }
                else if(response?.statusCode == 200){
                    self.performSegueWithIdentifier("registerOk", sender: nil)
                }
            }
        }
        else{
            alertViewForErrors("Tous les champs ne sont pas correctement remplis.")
        }
    }
    
    func patientView(){
        spin = UIActivityIndicatorView()
        spin.color = UIColor.blueColor()
        spin.frame = CGRectMake(self.view.frame.width/2, self.view.frame.height / 2, 5, 5)
        self.view.addSubview(spin)
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