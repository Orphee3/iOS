//
//  trackItemView.swift
//  CompoUI
//
//  Created by John Bobington on 27/01/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit

class trackItemView: UIView {

    @IBOutlet weak var deleteButton: UIButton!

    var activeColor = UIColor.darkGrayColor()
    var inactiveColor = UIColor.lightGrayColor()
    var active: Bool = false {
        willSet {
            if newValue == true { self.backgroundColor = self.activeColor }
            else { self.backgroundColor = self.inactiveColor }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 10
        self.autoresizingMask = UIViewAutoresizing.None
    }
}
