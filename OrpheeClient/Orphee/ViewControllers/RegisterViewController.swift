//
//  RegisterViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 28/02/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import UnderKeyboard
import MBProgressHUD

class RegisterViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var pseudoField: UITextField!
    @IBOutlet var mdpField: UITextField!
    @IBOutlet var errorLabel: UILabel!
    let underKeyboardLayoutConstraint = UnderKeyboardLayoutConstraint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        underKeyboardLayoutConstraint.setup(bottomLayoutConstraint, view: view,
                                            bottomLayoutGuide: bottomLayoutGuide)
        emailField.delegate = self
        pseudoField.delegate = self
        mdpField.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == emailField){
            pseudoField.becomeFirstResponder()
        } else if (textField == pseudoField){
            mdpField.becomeFirstResponder()
        } else if (textField == mdpField){
            registerAsked(self)
            return true
        } else {
            
        }
        return true
    }
    
    @IBAction func registerAsked(sender: AnyObject) {
        if (!(emailField.text?.isEmpty)! && !(pseudoField.text?.isEmpty)! && !(mdpField.text?.isEmpty)!){
            let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.Indeterminate
            loadingNotification.labelText = "Vérification..."
            loadingNotification.color = UIColor.lightGrayColor()

            OrpheeApi().register(pseudoField.text!, mail: emailField.text!, password: mdpField.text!, completion: { (response) in
                loadingNotification.hide(true, afterDelay: 1.0)
                if(response as! String == "exists"){
                    self.errorLabel.text = "Ce compte existe déjà"
                }
                if(response as! String == "ok"){
                    print("connected")
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        }
        else{
            self.errorLabel.text = "Tous les champs ne sont pas correctement remplis."
        }
    }
}