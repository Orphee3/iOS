//
//  scrollableToolbar.swift
//  Orphee
//
//  Created by John Bobington on 28/01/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit

class scrollableToolbar: UIBarButtonItem {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.customView = UIScrollView()
    }

}
