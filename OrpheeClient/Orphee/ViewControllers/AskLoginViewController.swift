//
//  AskLoginViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 14/08/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import UIKit

class AskLoginViewController: UIViewController {
    @IBOutlet var popUpView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.popUpView.layer.cornerRadius = 5
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
    }
    
    @IBAction func registerButton(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("register") as! UINavigationController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func facebookButton(sender: AnyObject) {
    }
    
    @IBAction func googleButton(sender: AnyObject) {
        
    }
    
    @IBAction func loginButton(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("login") as! UINavigationController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func showInView(aView: UIView!, animated: Bool)
    {
        aView.addSubview(self.view)
        if animated{
            self.showAnimate()
        }
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
        self.view.alpha = 0.0;
        UIView.animateWithDuration(0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animateWithDuration(0.25, animations: {
            self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished){
                    self.view.removeFromSuperview()
                }
        });
    }
    
    @IBAction func closePopup(sender: AnyObject) {
        self.removeAnimate()
    }
}
