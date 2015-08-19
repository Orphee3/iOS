//
//  StartViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 27/06/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {
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
        if (!loginField.text!.isEmpty && !mdpField.text!.isEmpty){
            let param = "\(loginField.text!):\(mdpField.text!)"
            let utf8str = param.dataUsingEncoding(NSUTF8StringEncoding)
            let token = utf8str!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            let headers = [
                "Authorization": "Bearer \(token)"
            ]
            print(token)
            Alamofire.request(.POST, "http://163.5.84.242:3000/api/login", headers: headers).responseJSON { request, response, json in
                print(response)
                print(request)
                print(json)
                if (response?.statusCode == 500){
                    self.alertViewForErrors("Une erreur s'est produite. Réessayer plus tard")
                }
                else if(response?.statusCode == 401){
                    self.alertViewForErrors("Les identifiants et le mot de passe ne correspondent pas")
                }
                else if (response?.statusCode == 200){
                    var json = JSON(json.value!)
                    NSUserDefaults.standardUserDefaults().setObject(json["token"].string, forKey: "token")
                    NSUserDefaults.standardUserDefaults().setObject(self.loginField.text, forKey: "userName")
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                }
            }
        }
        else{
            alertViewForErrors("Tous les champs ne sont pas correctement remplis")
        }
    }
    
    func alertViewForErrors(msg: String){
        let alertView = UIAlertView(title: "Erreur", message: msg , delegate: self, cancelButtonTitle: "Ok")
        alertView.alertViewStyle = .Default
        alertView.show()
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        print("bonjour")
        checkLoginAndPasswd()
        //performSegueWithIdentifier("toMenu", sender: nil)
    }
}