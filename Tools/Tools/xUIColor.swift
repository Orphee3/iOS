//
//  xUIColor.swift
//  Tools
//
//  Created by John Bobington on 23/01/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation

public extension UIColor {

    public static func randomColor() -> UIColor {

        return UIColor(red: CGFloat.rand0_1CGFloat(), green: CGFloat.rand0_1CGFloat(), blue: CGFloat.rand0_1CGFloat(), alpha: 1)
    }
}