//
//  xUITabBarController.swift
//  Tools
//
//  Created by John Bobington on 29/01/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit

extension UITabBarController {
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if let selected = selectedViewController {
            return selected.supportedInterfaceOrientations()
        }
        return super.supportedInterfaceOrientations()
    }

    public override func shouldAutorotate() -> Bool {
        if let selected = selectedViewController {
            return selected.shouldAutorotate()
        }
        return super.shouldAutorotate()
    }
}