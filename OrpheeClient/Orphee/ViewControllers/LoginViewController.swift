//
//  LoginViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 27/02/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import UnderKeyboard
import MBProgressHUD

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    let underKeyboardLayoutConstraint = UnderKeyboardLayoutConstraint()
    
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        underKeyboardLayoutConstraint.setup(bottomLayoutConstraint, view: view,
                                            bottomLayoutGuide: bottomLayoutGuide)
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField === emailField) {
            passwordField.becomeFirstResponder()
        } else if (textField === passwordField){
            proceedConnection()
            return true
        }
        else{
            //
        }
        return true
    }
    
    func proceedConnection(){
        print("connection")
        if (!emailField.text!.isEmpty && !passwordField.text!.isEmpty){
            let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.Indeterminate
            loadingNotification.labelText = "Vérification..."
            loadingNotification.color = UIColor.lightGrayColor()
            
            let param = "\(emailField.text!):\(passwordField.text!)"
            let utf8str = param.dataUsingEncoding(NSUTF8StringEncoding)
            let token = utf8str!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            
            OrpheeApi().login(token) { (user) in
                print(user)
                loadingNotification.hide(true, afterDelay: 1.0)
                if(user as! String == "mdp"){
                    self.errorLabel.text = "Les identifiants ne correspondent pas."
                }
                if(user as! String == "ok"){
                    print("connected")
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
        else{
            self.errorLabel.text = "Tous les champs ne sont pas correctement remplis."
        }
    }
}