//
//  NotConnectedView.swift
//  Orphee
//
//  Created by Jeromin Lebon on 21/11/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit

class NotConnectedView: UIView {
    @IBOutlet weak var goToLogin: UIButton!
    
    class func instanceFromNib() -> NotConnectedView {
        return UINib(nibName: "NotConnectedView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! NotConnectedView
    }
}