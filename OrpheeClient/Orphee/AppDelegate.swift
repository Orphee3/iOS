//
//  AppDelegate.swift
//  Orphee
//
//  Created by John Bob on 29/01/15.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import OAuthSwift
/// The app delegate works alongside the app object to ensure your app interacts properly with the system and with other apps.
/// Specifically, the methods of the app delegate give you a chance to respond to important changes
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    /// The application's window
    var window: UIWindow?;

    /// This view controller graph represents the view controllers for all or part of the application’s user interface.
    var storybd: UIStoryboard?;

    var makeLandscape = false

    /// Override point for customization after application launch.
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if (userExists()){
            SocketManager.sharedInstance.connectSocket()
        }
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        let pushNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
        GIDSignIn.sharedInstance().clientID = "1091784243585-a16tac0tegj6vh5mibln1s3m1qjia72a.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        let vc: CompositionVC? = storybd?.instantiateInitialViewController() as? CompositionVC;
        if let _ = vc {
            self.window?.rootViewController = vc!;
            self.window?.makeKeyAndVisible();
        }
        else {
            return false;
        }
        return true
    }

    func application(application: UIApplication,
                     openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        if (url.scheme == "fb560109060810772"){
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String, annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
        }else{
            return GIDSignIn.sharedInstance().handleURL(url,
                                                        sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String,
                                                        annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
        }
    }

    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if (error == nil) {
            OrpheeApi().loginByGoogle(user.profile.name, email: user.profile.email, id: user.userID, picture: user.profile.imageURLWithDimension(200).URLString, completion: { (response) in
                print("google ok")
            })
        } else {
            print("\(error.localizedDescription)")
        }
    }

    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }

    /// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    /// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    func applicationWillResignActive(application: UIApplication) {
    }

    /// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    /// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    func applicationDidEnterBackground(application: UIApplication) {
    }

    /// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    func applicationWillEnterForeground(application: UIApplication) {
    }

    /// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    func applicationDidBecomeActive(application: UIApplication) {
    }

    /// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    func applicationWillTerminate(application: UIApplication) {
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("tokenNotif")

        print(deviceToken)
        let isSaved = NSKeyedArchiver.archiveRootObject(deviceToken, toFile: ArchiveURL.path!)
        if (isSaved){
            print("token save OK")
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print(userInfo)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications();
    }
}

