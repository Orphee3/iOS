//
//  xUIImageView.swift
//  Tools
//
//  Created by John Bobington on 26/03/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit

public extension UIImageView {
    @IBInspectable var imageTint: UIColor {
        get {
            return self.tintColor
        }
        set {
            self.tintColor = newValue
        }
    }

    @IBInspectable var imageBorderColor: UIColor? {
        get {
            if let color = self.layer.borderColor {
                return UIColor(CGColor: color)
            }
            return nil
        }
        set {
            self.layer.borderColor = newValue?.CGColor
        }
    }

    @IBInspectable var imageBorderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
}