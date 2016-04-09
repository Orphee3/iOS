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
    @IBOutlet weak var muteButton: UIButton!

    var activeColor = UIColor.darkGrayColor()
    var inactiveColor = UIColor.lightGrayColor()
    var mutedColor = UIColor.blueColor()
    var unmutedColor = UIColor.blackColor()
    var mutedImage = UIImage(named: "player/volume/mute")
    var unmutedImage = UIImage(named: "player/volume/high")
    var active: Bool = false {
        willSet {
            if newValue == true { self.backgroundColor = self.activeColor }
            else { self.backgroundColor = self.inactiveColor }
        }
    }

    var muted: Bool = false {
        willSet {
            if newValue == true {
                self.muteButton.borderColor = self.mutedColor
                self.muteButton.setImage(self.mutedImage, forState: .Normal)
            }
            else {
                self.muteButton.borderColor = self.unmutedColor
                self.muteButton.setImage(self.unmutedImage, forState: .Normal)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 10
        self.autoresizingMask = UIViewAutoresizing.None
    }
}
