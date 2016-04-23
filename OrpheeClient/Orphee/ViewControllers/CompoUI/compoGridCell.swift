//
//  CompoGridCell.swift
//
//
//  Created by John Bobington on 22/04/2016.
//
//

import UIKit
import MDSpreadView

class CompoGridCell: MDSpreadViewCell {

    var touchRecon = UITapGestureRecognizer()

    var active: Bool = false {
        willSet(isActive) {
            self.backgroundView.backgroundColor = isActive ? .redColor() : .grayColor()
        }
    }

    var graph: AudioGraph?
    var note = 0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: MDSpreadViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.touchRecon.delegate = self
        self.backgroundColor = .whiteColor()
    }

    

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !self.active {
            self.graph?.playNote(UInt32(self.note))
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.graph?.stopNote(UInt32(self.note))
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        self.graph?.stopNote(UInt32(self.note))
    }
}
