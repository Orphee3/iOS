//
//  CreationViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 01/03/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import NextGrowingTextView

class CreationViewController: UIViewController {
    var creation: Creation!
    
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var inputContainerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var growingTextView: NextGrowingTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        self.growingTextView.layer.cornerRadius = 4
        self.growingTextView.backgroundColor = UIColor(white: 0.9, alpha: 1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    dynamic func keyboardWillChangeFrame(notification: NSNotification) {
        if let newHeight = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height {
            self.inputContainerViewBottom.constant = newHeight - self.inputContainerView.frame.height
        }
    }
    
    @IBAction func handleSendButton(sender: AnyObject) {
        
        self.growingTextView.text = ""
    }
}