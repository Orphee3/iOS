//
//  OauthConnectionViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 06/03/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import OAuthSwift
import Alamofire

class OAuthConnectionViewController: UIViewController, UIWebViewDelegate, GIDSignInUIDelegate{
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        print("viewdidload")
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.center = CGPointMake(self.view.center.x, self.view.center.y + loginButton.frame.size.height * 2)
        self.view.addSubview(loginButton)
        
        let googleButton = GIDSignInButton()
        googleButton.center = CGPointMake(self.view.center.x, self.view.center.y + loginButton.frame.size.height * 2)
        self.view.addSubview(googleButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if (FBSDKAccessToken.currentAccessToken() != nil){
            _ = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id,name,email,picture"]).startWithCompletionHandler({ (connection, result, error) in
                if ((error == nil)){
                    print(result)
                    OrpheeApi().loginByFacebook(result["name"] as! String, email: result["email"] as! String, id: result["id"] as! String, picture: result["picture"]!!["data"]!!["url"] as! String, completion: { (response) in
                        print(response)
                    })
                }
            })
        }
        print("viewwillappear")
    }
}