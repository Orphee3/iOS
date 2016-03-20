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
        var loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.center = self.view.center
        self.view.addSubview(loginButton)
        
        var googleButton = GIDSignInButton()
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
    
    func webViewDidFinishLoad(webView: UIWebView) {
        print("finish load")
    }
    
    @IBAction func googleTapped(sender: AnyObject) {
        let oauthswift = OAuth2Swift(
            consumerKey:    "1091784243585-a16tac0tegj6vh5mibln1s3m1qjia72a.apps.googleusercontent.com",         // 2 Enter google app settings
            consumerSecret: "YOUR_GOOGLE_CLIENT_SECRET",
            authorizeUrl:   "https://accounts.google.com/o/oauth2/auth",
            accessTokenUrl: "https://accounts.google.com/o/oauth2/token",
            responseType:   "code"
        )
        let state: String = generateStateWithLength(20) as String
        oauthswift.authorize_url_handler = SafariURLHandler(viewController: self)
        oauthswift.authorizeWithCallbackURL( NSURL(string: "com.orphee.ios:/google")!, scope: "https://www.googleapis.com/auth/plus.me", state: state, success: {
            credential, response, parameters in
            print("ok")
            }, failure: { error in
                print("ERROR: \(error.localizedDescription)")
        })
    }
}