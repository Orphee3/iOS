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

    var pos: Int = 0 {
        willSet(x) {
            self.originX = x * (UITrackTimeBlock.width + 10) + 10;
        }
    }

    var row: Int = 0 {
        willSet(y) {
            self.originY = y * (UITrackTimeBlock.height + 10);
        }
    }

    var originX: Int = 0 {
        willSet(x) {
            self.frame.origin.x = CGFloat(x);
        }
    }

    var originY: Int = 0 {
        willSet(y) {
            self.frame.origin.y = CGFloat(y);
        }
    }

    var endX: Int {
        get{
            return (self.originX + UITrackTimeBlock.width);
        }
    }

    var endY: Int {
        get {
            return (self.originY + UITrackTimeBlock.height);
        }
    }
    class func timeBlock(#color: UIColor, row: Int, column: Int) -> UITrackTimeBlock {

        var tBlock: UITrackTimeBlock = UITrackTimeBlock(row: row, column: column);

        tBlock.pos = column;
        tBlock.row = row;
        tBlock.layer.borderWidth = 5;
        tBlock.backgroundColor = color;
        tBlock.addTarget(tBlock, action: Selector("onClick"), forControlEvents: UIControlEvents.TouchUpInside);
        return tBlock;
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);

        var frame = self.frame;
        self.originX = Int(frame.origin.x);
        self.originY = Int(frame.origin.y);
    }

    init(row: Int, column: Int) {
        super.init(frame: CGRect(x: 0, y: 0, width: UITrackTimeBlock.width, height: UITrackTimeBlock.height));

        self.pos = column;
        self.row = row;
    }

    private init(pos_x: Int, pos_y: Int) {
        super.init(frame: CGRect(x: pos_x, y: pos_y, width: UITrackTimeBlock.width, height: UITrackTimeBlock.height));

        self.pos = pos_x / (UITrackTimeBlock.width + 10);
        self.row = pos_y / (UITrackTimeBlock.height + 10);
    }

    func onClick() {

        println("button #\(pos) on row #\(row)");
    }
}