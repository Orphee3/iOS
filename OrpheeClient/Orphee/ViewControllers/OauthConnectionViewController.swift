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

class OAuthConnectionViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func fbTapped(sender: AnyObject) {
        
    }
    
    @IBAction func googleTapped(sender: AnyObject) {
        let oauthswift = OAuth2Swift(
            consumerKey:    "1091784243585-a16tac0tegj6vh5mibln1s3m1qjia72a.apps.googleusercontent.com",         // 2 Enter google app settings
            consumerSecret: "YOUR_GOOGLE_DRIVE_CLIENT_SECRET",
            authorizeUrl:   "https://accounts.google.com/o/oauth2/auth",
            accessTokenUrl: "https://accounts.google.com/o/oauth2/token",
            responseType:   "code"
        )
        
        oauthswift.authorizeWithCallbackURL( NSURL(string: "com.orphee.ios:/google")!, scope: "https://www.googleapis.com/auth/plus.me", state: "", success: {
            credential, response, parameters in
            print("ok")
            }, failure: { error in
                print("ERROR: \(error.localizedDescription)")
        })
    }
}