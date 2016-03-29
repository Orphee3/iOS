//
//  xUIButton.swift
//  Tools
//
//  Created by John Bobington on 26/03/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit

public extension UIButton {

    @IBInspectable var buttonTint: UIColor? {
        get {
            return self.imageView?.tintColor
        }
        set {
            self.imageView?.tintColor = newValue
        }
    }

    @IBInspectable var imageBorderColor: UIColor? {
        get {
            if let color = self.imageView?.layer.borderColor {
                return UIColor(CGColor: color)
            }
            return nil
        }
        set {
            self.imageView?.layer.borderColor = newValue?.CGColor
        }
    }

    @IBInspectable var imgBorderWidth: CGFloat {
        get {
            return self.imageView!.layer.borderWidth
        }
        set {
            self.imageView?.layer.borderWidth = newValue
            self.imageView?.layer.masksToBounds = true
        }
    }
}
