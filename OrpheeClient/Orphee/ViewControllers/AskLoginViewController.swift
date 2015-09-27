//
//  AskLoginViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 14/08/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import UIKit

class AskLoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func facebookButton(sender: AnyObject) {
    }
    
    @IBAction func googleButton(sender: AnyObject) {
        
    }
    
    @IBAction func closePopup(sender: AnyObject) {
        print("ça close")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
