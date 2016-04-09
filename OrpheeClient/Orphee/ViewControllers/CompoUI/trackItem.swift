//
//  trackItem.swift
//  CompoUI
//
//  Created by John Bobington on 27/01/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit

class trackItem: UIBarButtonItem {

    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.customView = NSBundle.mainBundle().loadNibNamed("trackItemView", owner: self, options: nil)[0] as! trackItemView
    }
}
