//
//  xCollectionViewFlowLayout.swift
//  Tools
//
//  Created by John Bobington on 30/01/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit

public extension UICollectionViewFlowLayout {
    @IBInspectable var pinHeaders: Bool {
        get {
            return self.sectionHeadersPinToVisibleBounds
        }
        set {
            sectionHeadersPinToVisibleBounds = newValue
        }
    }

    @IBInspectable var pinFooters: Bool {
        get {
            return self.sectionFootersPinToVisibleBounds
        }
        set {
            sectionFootersPinToVisibleBounds = newValue
        }
    }
}
