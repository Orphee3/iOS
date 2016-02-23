//
//  xUINavigationController.swift
//  Tools
//
//  Created by John Bobington on 29/01/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit

extension UINavigationController {
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return (self.visibleViewController?.supportedInterfaceOrientations() ?? .AllButUpsideDown)
    }

    public override func shouldAutorotate() -> Bool {
        return (self.visibleViewController?.shouldAutorotate() ?? true)
    }
}
