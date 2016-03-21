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

    public convenience init(r: Int, g: Int, b: Int, alpha: CGFloat) {
//        let red = CGFloat(r) / 255
//        let green = CGFloat(g) / 255
//        let blue = CGFloat(b) / 255
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: alpha)
    }
}