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

class RegisterViewController: UIViewController {
    @IBOutlet var mailTextField: UITextField!
    @IBOutlet var pseudoTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    var spin: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    func sendInfosToServer(){
        if (!mailTextField.text!.isEmpty && !passwordTextField.text!.isEmpty && !pseudoTextField.text!.isEmpty){
            OrpheeApi().register(pseudoTextField.text!, mail: mailTextField.text!, password: passwordTextField.text!, completion: {(response) -> () in
                if (response as! String == "error"){
                    self.alertViewForErrors("Erreur de connexion, veuillez réessayer plus tard")
                }
                else if (response as! String == "exists"){
                    self.alertViewForErrors("Utilisateur déjà existant.")
                }
                else if (response as! String == "ok"){
                    self.loginInstant()
                }
            })
        }
        else{
            alertViewForErrors("Tous les champs ne sont pas correctement remplis.")
        }
    }
    
    func loginInstant() {
        let param = "\(mailTextField.text!):\(passwordTextField.text!)"
        let utf8str = param.dataUsingEncoding(NSUTF8StringEncoding)
        let token = utf8str!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        OrpheeApi().login(token, completion: {(response) -> () in
            if (response as! String == "error"){
                self.alertViewForErrors("Une erreur s'est produite. Réessayer plus tard")
            }
            else if (response as! String == "wrong mdp"){
                self.alertViewForErrors("Les identifiants et le mot de passe ne correspondent pas")
            }
            else if (response as! String == "ok"){
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
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