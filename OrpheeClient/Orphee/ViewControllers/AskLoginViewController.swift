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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController!.navigationBar.barTintColor = UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    @IBAction func facebookButton(sender: AnyObject) {
    }
    
    @IBAction func googleButton(sender: AnyObject) {
        
    }
    
    @IBAction func closePopup(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
