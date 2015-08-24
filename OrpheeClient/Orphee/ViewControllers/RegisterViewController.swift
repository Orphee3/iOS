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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (13/255.0), green: (71/255.0), blue: (161/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    func sendInfosToServer(){
        if (!loginTextField.text!.isEmpty && !passwordTextField.text!.isEmpty){
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
                    self.loginInstant()
                }
            }
        }
        else{
            alertViewForErrors("Tous les champs ne sont pas correctement remplis.")
        }
    }
    
    func loginInstant() {
        let param = "\(loginTextField.text!):\(passwordTextField.text!)"
        let utf8str = param.dataUsingEncoding(NSUTF8StringEncoding)
        let token = utf8str!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        print(token)
        Alamofire.request(.POST, "http://163.5.84.242:3000/api/login", headers: headers).responseJSON { request, response, json in
            print("LOGIN : \(json)")
            if (response?.statusCode == 500){
                self.alertViewForErrors("Une erreur s'est produite. Réessayer plus tard")
            }
            else if(response?.statusCode == 401){
                self.alertViewForErrors("Les identifiants et le mot de passe ne correspondent pas")
            }
            else if (response?.statusCode == 200){
                var json = JSON(json.value!)
                NSUserDefaults.standardUserDefaults().setObject(json["token"].string, forKey: "token")
                NSUserDefaults.standardUserDefaults().setObject(self.loginTextField.text!, forKey: "userName")
                NSUserDefaults.standardUserDefaults().setObject(json["user"]["_id"].string, forKey: "myId")
                print(NSUserDefaults.standardUserDefaults().objectForKey("myId"))
                self.dismissViewControllerAnimated(true, completion: nil)
            }
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
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}