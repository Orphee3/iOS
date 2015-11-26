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

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var loginField: UITextField!
    @IBOutlet var mdpField: UITextField!
    @IBOutlet var forgetMdp: UIButton!
    
    var mailFieldForForgetPwd: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginField.delegate = self;
        mdpField.delegate = self;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func checkLoginAndPasswd() {
        if (!loginField.text!.isEmpty && !mdpField.text!.isEmpty){
            let param = "\(loginField.text!):\(mdpField.text!)"
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
        else{
            alertViewForErrors("Tous les champs ne sont pas correctement remplis")
        }
    }
    
    func alertViewForErrors(msg: String){
        let alertView = UIAlertView(title: "Erreur", message: msg , delegate: self, cancelButtonTitle: "Ok")
        alertView.alertViewStyle = .Default
        alertView.show()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        checkLoginAndPasswd()
    }
    
    @IBAction func forgetPassword(sender: AnyObject){
        let alertController = UIAlertController(title: "Mot de passe oublié", message: "Veuillez indiquer votre email pour recevoir un lien de changement de mot de passe", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler{textField -> Void in
            self.mailFieldForForgetPwd = textField
        }
        
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
            print(self.mailFieldForForgetPwd.text)
            if (!self.mailFieldForForgetPwd.text!.isEmpty){
                OrpheeApi().lostPassword(self.mailFieldForForgetPwd.text!, completion: { (response) -> () in
                    if (response as! String == "ok"){
                        self.alertViewForErrors("Votre demande a bien été prise en compte, vous allez recevoir un email pour la suite de la procédure")
                    }
                })
            }
            else{
                self.alertViewForErrors("Veuillez remplir le champ")
            }
        }
        alertController.addAction(okAction)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Destructive, handler: nil)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}