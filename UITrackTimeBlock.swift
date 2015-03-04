//
//  UITrackTimeBlock.swift
//  Orphee
//
//  Created by JohnBob on 04/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

class UITrackTimeBlock: UIButton {

    class var width: Int { return 50; };
    class var height: Int { return 50; };

    var pos: Int = 0;
    var row: Int = 0;

    var originX: Int = 0;
    var originY: Int = 0;
    var endX: Int = 0;
    var endY: Int = 0;

    class func timeBlock(#color: UIColor, row: Int, column: Int) -> UITrackTimeBlock {

        var tBlock: UITrackTimeBlock = UITrackTimeBlock(pos_x: column * (width + 10), pos_y: row * (height + 10));

        tBlock.backgroundColor = color;
        return tBlock;
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);

        var frame = self.frame;
        self.originX = Int(frame.origin.x);
        self.originY = Int(frame.origin.y);
        self.endX = self.originX + Int(frame.width);
        self.endY = self.originY + Int(frame.height);
    }

    private init(pos_x: Int, pos_y: Int) {
        super.init(frame: CGRect(x: pos_x, y: pos_y, width: UITrackTimeBlock.width, height: UITrackTimeBlock.height));

        self.originX = pos_x;
        self.originY = pos_y;
        self.endX = pos_x + UITrackTimeBlock.width;
        self.endY = pos_y + UITrackTimeBlock.height;
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event);

        println("button #\(pos) touched on line \(row)");
    }
}